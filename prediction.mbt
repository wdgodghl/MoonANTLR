///|
pub(all) enum PredictionMode {
  SLL
  LL
  LL_EXACT_AMBIG_DETECTION
}

///|
/// Committed host actions may change settings at the same sites as ANTLR.
pub(all) struct ParserControl {
  mut prediction_mode : PredictionMode
  mut build_tree : Bool
  mut bail : Bool
  mut dfa : String
}

///|
pub fn ParserControl::dump_dfa(self : ParserControl) -> String {
  self.dfa
}

///|
#derive(Debug, Eq, ToJson)
pub(all) struct PredictionEvent {
  kind : String
  decision : Int32
  start : Int32
  stop : Int32
  exact : Bool
  alternatives : Array[Int32]
  prediction : Int32
}

///|
pub extend PredictionEvent with @debug.Debug::{to_repr}

///|
pub extend PredictionEvent with Eq::{equal, not_equal}

///|
pub extend PredictionEvent with ToJson::{to_json}

///|
/// Observable counters for one parse; DFA storage is isolated per parse.
pub(all) struct PredictionStatistics {
  decisions : Int32
  full_context_fallbacks : Int32
  dfa_states : Int32
  dfa_hits : Int32
  max_lookahead : Int32
}

///|
pub(all) struct ParseResult {
  context : RuleContext
  frame : RuleFrame?
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
  entry : Int32
  finished : Bool
  follow_outer : Bool
  collect : Bool
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
  starts : Map[(Int32, Int32, Int32, Bool, Bool), Int32]
  mut check : ((Int32, Int32, Bool) -> Bool raise RuntimeError)?
  follows : Array[Array[Int32]]
  mut decisions : Int32
  mut fallbacks : Int32
  mut hits : Int32
  mut max_lookahead : Int32
  mut failure_pos : Int32
  mut mode : PredictionMode
  events : Array[PredictionEvent]
  adaptive_dfas : Map[Int32, AdaptiveDfa]
}

///|
fn Predictor::new(atn : Atn, budget : Budget) -> Predictor {
  let follows : Array[Array[Int32]] = Array::makei(atn.starts.length(), _ => [])
  for state in atn.states {
    for edge in state.edges {
      if edge.kind == 3 && !follows[edge.b].contains(edge.target) {
        follows[edge.b].push(edge.target)
      }
    }
  }
  {
    follows,
    check: None,
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
    max_lookahead: 0,
    failure_pos: 0,
    mode: LL,
    events: [],
    adaptive_dfas: Map([]),
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
  "\{self.state}:\{self.edge}:\{self.alt}:\{self.context}:\{self.precedence}:\{self.entry}:\{self.finished}:\{self.follow_outer}:\{self.collect}"
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
      let cfg = { ..cfg, finished: cfg.finished || cfg.context == cfg.entry, }
      if cfg.context == 0 {
        if !accepted.contains(cfg.alt) {
          accepted.push(cfg.alt)
        }
        if cfg.follow_outer {
          for follow in self.follows[state.rule] {
            work.push({ ..cfg, state: follow, edge: -1, precedence: 0, })
          }
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
        1 => work.push({ ..cfg, state: edge.target, edge: -1, })
        6 => work.push({ ..cfg, state: edge.target, edge: -1, collect: false, })
        4 => {
          let visible = cfg.collect && (edge.c == 0 || cfg.context == cfg.entry)
          if !visible ||
            self.check is None ||
            self.check.unwrap()(edge.a, edge.b, edge.c != 0) {
            work.push({ ..cfg, state: edge.target, edge: -1, })
          }
        }
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
  follow_outer~ : Bool = false,
  collect~ : Bool = true,
) -> Int32 raise RuntimeError {
  let key = (state, precedence, context, follow_outer, collect)
  if self.starts.get(key) is Some(id) {
    self.hits += 1
    return id
  }
  let seeds : Array[PredictionConfig] = []
  for i in 0..<self.atn.states[state].edges.length() {
    seeds.push({
      state,
      edge: i,
      alt: i,
      context,
      precedence,
      entry: context,
      finished: false,
      follow_outer,
      collect,
    })
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
      seeds.push({ ..cfg, state: edge.target, edge: -1, collect: false, })
    }
  }
  let next = self.closure(seeds)
  // Rule-stop configurations survive EOF reach operations (skippedStopStates
  // in ParserATNSimulator); they must not be replaced by local-failure alts.
  let next = if token == -1 && !state.accepted.is_empty() {
    let reached = self.states[next]
    let accepted = reached.accepted.copy()
    for alt in state.accepted {
      if !accepted.contains(alt) {
        accepted.push(alt)
      }
    }
    accepted.sort()
    let id = self.states.length()
    self.states.push({ configs: reached.configs, accepted, edges: Map([]), })
    id
  } else {
    next
  }
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
/// PredictionMode.hasSLLConflictTerminatingPrediction: conflicting subsets
/// terminate SLL only when no ATN state is associated with a single alt.
fn DfaState::sll_conflict(self : DfaState) -> Bool {
  let subsets : Map[(Int32, Int32), Array[Int32]] = Map([])
  let states : Map[Int32, Array[Int32]] = Map([])
  for cfg in self.configs {
    let subset = subsets.get_or_init((cfg.state, cfg.context), () => [])
    if !subset.contains(cfg.alt) {
      subset.push(cfg.alt)
    }
    let alts = states.get_or_init(cfg.state, () => [])
    if !alts.contains(cfg.alt) {
      alts.push(cfg.alt)
    }
  }
  if !self.accepted.is_empty() {
    subsets[(-1, 0)] = self.accepted
    states[-1] = self.accepted
  }
  subsets.values().any(alts => alts.length() > 1) &&
  !states.values().any(alts => alts.length() == 1)
}

///|
/// Look ahead until one alternative remains, the ATN stops, or input ends.
/// Cache hits still spend work budget, so cyclic DFA paths remain bounded.
fn Predictor::simulate(
  self : Predictor,
  initial : Int32,
  tokens : ParserInput,
  pos : Int32,
  sll~ : Bool = false,
) -> Array[Int32] raise RuntimeError {
  let mut id = initial
  let mut offset = 0
  while true {
    self.budget.tick()
    let state = self.states[id]
    let alts = state.alternatives()
    if alts.length() <= 1 ||
      state.configs.is_empty() ||
      (sll && state.sll_conflict()) {
      return alts
    }
    self.max_lookahead = self.max_lookahead.max(offset + 1)
    let token = tokens.token(pos + offset)
    let next = self.advance(id, token.kind)
    if self.states[next].alternatives().is_empty() {
      self.failure_pos = pos + offset
      let finished = state.accepted.copy()
      for cfg in state.configs {
        if cfg.finished && !finished.contains(cfg.alt) {
          finished.push(cfg.alt)
        }
      }
      if !finished.is_empty() {
        finished.sort()
        return [finished[0]]
      }
      return []
    }
    id = next
    if token.kind == -1 {
      return self.states[id].alternatives()
    }
    offset += 1
  } nobreak {
    []
  }
}

///|
fn Predictor::predict(
  self : Predictor,
  state : Int32,
  precedence : Int32,
  context : Int32,
  tokens : ParserInput,
  pos : Int32,
  terminal_loop~ : Bool = false,
) -> Array[Int32] raise RuntimeError {
  self.decisions += 1
  self.failure_pos = pos
  let start = self.start(state, precedence, 0, follow_outer=true)
  let immediate = if terminal_loop {
    self.start(state, precedence, 0)
  } else {
    start
  }
  // At a greedy loop at the end of an entry rule, a token belonging
  // uniquely to the body commits that iteration. A missing operand may
  // then raise instead of turning the broken iteration into trailing input.
  if terminal_loop && !self.states[immediate].accepted.is_empty() {
    let viable : Array[Int32] = []
    let token = tokens.token(pos).kind
    for cfg in self.states[immediate].configs {
      self.budget.tick()
      if cfg.context == 0 &&
        self.atn.matches(self.atn.states[cfg.state].edges[cfg.edge], token) &&
        !viable.contains(cfg.alt) {
        viable.push(cfg.alt)
      }
    }
    let caller = self.start(state, precedence, context)
    let caller_accepts = !(self.mode is SLL) &&
      context != 0 &&
      self.states[caller].configs.any(cfg => {
        self.states[immediate].accepted.contains(cfg.alt) &&
        self.atn.matches(self.atn.states[cfg.state].edges[cfg.edge], token)
      })
    if !caller_accepts &&
      viable.length() == 1 &&
      !self.states[immediate].accepted.contains(viable[0]) {
      return viable
    }
  }
  let sll = self.simulate(start, tokens, pos, sll=true)
  if self.mode is SLL || sll.length() <= 1 || context == 0 {
    return sll
  }
  self.fallbacks += 1
  self.simulate(self.start(state, precedence, context), tokens, pos)
}
