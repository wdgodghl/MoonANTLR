///|
/// Observable counters for one parse; DFA storage is isolated per parse.
pub(all) struct PredictionStatistics {
  decisions : Int32
  full_context_fallbacks : Int32
  dfa_states : Int32
  dfa_hits : Int32
}

///|
pub(all) struct ParseResult {
  context : RuleContext
  prediction : PredictionStatistics
}

///|
/// Interned return contexts share tails; precedence is restored on rule exit.
priv struct ReturnContext {
  state : Int32
  precedence : Int32
  parent : Int32
}

///|
priv struct PredictionConfig {
  state : Int32
  edge : Int32
  alt : Int32
  context : Int32
  precedence : Int32
}

///|
priv struct DfaState {
  configs : Array[PredictionConfig]
  accepted : Array[Int32]
  edges : Map[Int32, Int32]
}

///|
priv struct Predictor {
  atn : Atn
  budget : Budget
  returns : Array[ReturnContext]
  contexts : Map[(Int32, Int32, Int32), Int32]
  states : Array[DfaState]
  interned : Map[String, Int32]
  starts : Map[(Int32, Int32, Int32), Int32]
  mut decisions : Int32
  mut fallbacks : Int32
  mut hits : Int32
}

///|
fn Predictor::new(atn : Atn, budget : Budget) -> Predictor {
  {
    atn,
    budget,
    returns: [{ state: -1, precedence: 0, parent: 0, }],
    contexts: Map([]),
    states: [],
    interned: Map([]),
    starts: Map([]),
    decisions: 0,
    fallbacks: 0,
    hits: 0,
  }
}

///|
fn Predictor::push(
  self : Predictor,
  state : Int32,
  precedence : Int32,
  parent : Int32,
) -> Int32 {
  let key = (state, precedence, parent)
  if self.contexts.get(key) is Some(id) {
    return id
  }
  let id = self.returns.length()
  self.returns.push({ state, precedence, parent, })
  self.contexts[key] = id
  id
}

///|
fn PredictionConfig::key(self : PredictionConfig) -> String {
  "\{self.state}:\{self.edge}:\{self.alt}:\{self.context}:\{self.precedence}"
}

///|
/// Epsilon closure includes internal rule calls and precedence predicates.
/// A stopped outer context is an accepting wildcard in SLL mode. Including
/// the caller's interned return context produces the full-context simulation.
fn Predictor::closure(
  self : Predictor,
  seeds : Array[PredictionConfig],
) -> Int32 raise RuntimeError {
  let work = seeds.copy()
  let seen : Map[String, Bool] = Map([])
  let configs : Array[PredictionConfig] = []
  let accepted : Array[Int32] = []
  while work.pop() is Some(cfg) {
    self.budget.tick()
    let key = cfg.key()
    if seen.contains(key) {
      continue
    }
    seen[key] = true
    let state = self.atn.states[cfg.state]
    if state.kind == 7 {
      if cfg.context == 0 {
        if !accepted.contains(cfg.alt) {
          accepted.push(cfg.alt)
        }
      } else {
        let ret = self.returns[cfg.context]
        work.push({
          ..cfg,
          state: ret.state,
          edge: -1,
          context: ret.parent,
          precedence: ret.precedence,
        })
      }
      continue
    }
    for i, edge in state.edges {
      if cfg.edge >= 0 && cfg.edge != i {
        continue
      }
      match edge.kind {
        1 | 6 => work.push({ ..cfg, state: edge.target, edge: -1, })
        10 =>
          if edge.a >= cfg.precedence {
            work.push({ ..cfg, state: edge.target, edge: -1, })
          }
        3 => {
          // Recursive nullable calls must terminate under the shared work budget.
          let context = self.push(edge.target, cfg.precedence, cfg.context)
          work.push({
            ..cfg,
            state: edge.a,
            edge: -1,
            context,
            precedence: edge.c,
          })
        }
        2 | 5 | 7 | 8 | 9 => configs.push({ ..cfg, edge: i, })
        _ => raise Unsupported("prediction requires action-free grammar")
      }
    }
  }
  let keys = configs.map(c => c.key())
  keys.sort()
  accepted.sort()
  let key = keys.join(";") + "/" + accepted.map(a => a.to_string()).join(",")
  if self.interned.get(key) is Some(id) {
    self.hits += 1
    return id
  }
  let id = self.states.length()
  self.states.push({ configs, accepted, edges: Map([]), })
  self.interned[key] = id
  id
}

///|
fn Predictor::start(
  self : Predictor,
  state : Int32,
  precedence : Int32,
  context : Int32,
) -> Int32 raise RuntimeError {
  let key = (state, precedence, context)
  if self.starts.get(key) is Some(id) {
    self.hits += 1
    return id
  }
  let seeds : Array[PredictionConfig] = []
  for i in 0..<self.atn.states[state].edges.length() {
    seeds.push({ state, edge: i, alt: i, context, precedence, })
  }
  let id = self.closure(seeds)
  self.starts[key] = id
  id
}

///|
fn Predictor::advance(
  self : Predictor,
  id : Int32,
  token : Int32,
) -> Int32 raise RuntimeError {
  let state = self.states[id]
  if state.edges.get(token) is Some(next) {
    self.hits += 1
    return next
  }
  let seeds : Array[PredictionConfig] = []
  for cfg in state.configs {
    let edge = self.atn.states[cfg.state].edges[cfg.edge]
    if self.atn.matches(edge, token) {
      seeds.push({ ..cfg, state: edge.target, edge: -1, })
    }
  }
  let next = self.closure(seeds)
  state.edges[token] = next
  next
}

///|
fn DfaState::alternatives(self : DfaState) -> Array[Int32] {
  let alts = self.accepted.copy()
  for cfg in self.configs {
    if !alts.contains(cfg.alt) {
      alts.push(cfg.alt)
    }
  }
  alts.sort()
  alts
}

///|
/// Adaptive lookahead with conservative bounded fallback. When 64 tokens do
/// not settle a decision, every surviving alternative remains available to
/// the memoized parser; no unresolved alternative is silently discarded.
fn Predictor::simulate(
  self : Predictor,
  initial : Int32,
  tokens : Array[Token],
  pos : Int32,
) -> Array[Int32] raise RuntimeError {
  let mut id = initial
  let stopped : Array[Int32] = []
  for offset in 0..<64 {
    let state = self.states[id]
    for alt in state.accepted {
      if !stopped.contains(alt) {
        stopped.push(alt)
      }
    }
    let alts = state.alternatives()
    for alt in stopped {
      if !alts.contains(alt) {
        alts.push(alt)
      }
    }
    if alts.length() <= 1 ||
      pos + offset >= tokens.length() ||
      state.configs.is_empty() {
      return alts
    }
    id = self.advance(id, tokens[pos + offset].kind)
  }
  let alts = self.states[id].alternatives()
  for alt in stopped {
    if !alts.contains(alt) {
      alts.push(alt)
    }
  }
  alts
}

///|
fn Predictor::predict(
  self : Predictor,
  state : Int32,
  precedence : Int32,
  context : Int32,
  tokens : Array[Token],
  pos : Int32,
) -> Array[Int32] raise RuntimeError {
  self.decisions += 1
  let sll = self.simulate(self.start(state, precedence, 0), tokens, pos)
  if sll.length() <= 1 || context == 0 {
    return sll
  }
  self.fallbacks += 1
  self.simulate(self.start(state, precedence, context), tokens, pos)
}
