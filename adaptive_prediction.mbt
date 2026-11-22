// Adapted from ANTLR 4.13.2 ParserATNSimulator and PredictionMode.
// BSD-3-Clause; see licenses/ANTLR-LICENSE.txt.

///|
priv struct AdaptiveDfaState {
  edges : Map[Int32, Int32]
  accept : Bool
  full : Bool
  prediction : Int32
  predicates : Array[(String, Int32)]
}

///|
priv struct AdaptiveDfa {
  states : Array[AdaptiveDfaState]
  interned : Map[String, Int32]
}

///|
fn AdaptiveDfa::intern(
  self : AdaptiveDfa,
  configs : Array[AdaptiveConfig],
  accept : Bool,
  full : Bool,
) -> Int32 {
  let contexts : Map[(Int32, Int32, String), Array[Int32]] = Map([])
  for cfg in configs {
    let group = contexts.get_or_init((cfg.state, cfg.alt, cfg.semantic_key()), () => {
      []
    })
    if !group.contains(cfg.context) {
      group.push(cfg.context)
    }
  }
  let parts : Array[String] = []
  for (state, alt, predicate), group in contexts {
    group.sort()
    let key = if group.contains(0) {
      "0"
    } else {
      group.map(c => c.to_string()).join(",")
    }
    parts.push("\{state}:\{alt}:\{predicate}:\{key}")
  }
  parts.sort()
  let key = parts.join(";")
  if self.interned.get(key) is Some(id) {
    return id
  }
  let alts = adaptive_alternatives(configs)
  let predicates : Array[(String, Int32)] = []
  if accept && configs.any(cfg => !cfg.predicates.is_empty()) {
    for alt in alts {
      let expressions : Array[String] = []
      for cfg in configs {
        if cfg.alt == alt {
          let text = cfg.predicates
            .map(p => {
              if p.0 == -1 {
                "{\{p.1}>=prec}?"
              } else {
                "{\{p.0}:\{p.1}}?"
              }
            })
            .join("&&")
          if !expressions.contains(text) {
            expressions.push(text)
          }
        }
      }
      let text = if expressions.contains("") {
        "{true}?"
      } else {
        expressions.join("||")
      }
      predicates.push((text, alt + 1))
    }
  }
  let id = self.states.length()
  self.interned[key] = id
  self.states.push({
    edges: Map([]),
    accept,
    full,
    prediction: if alts.is_empty() {
      0
    } else {
      alts[0] + 1
    },
    predicates,
  })
  id
}

///|
fn AdaptiveDfaState::label(self : AdaptiveDfaState, id : Int32) -> String {
  let base = (if self.accept { ":" } else { "" }) +
    "s" +
    id.to_string() +
    (if self.full { "^" } else { "" })
  if !self.accept {
    return base
  }
  base +
  "=>" +
  (if self.predicates.is_empty() {
    self.prediction.to_string()
  } else {
    "[" +
    self.predicates
    .map(p => "(" + p.0 + ", " + p.1.to_string() + ")")
    .join(", ") +
    "]"
  })
}

///|
fn Predictor::adaptive_dump(self : Predictor, grammar : Grammar) -> String {
  let ids = self.adaptive_dfas.keys().collect()
  ids.sort()
  let output = StringBuilder()
  for n, decision in ids {
    if n > 0 {
      output.write_string("\n")
    }
    output.write_string("Decision " + decision.to_string() + ":\n")
    let dfa = self.adaptive_dfas[decision]
    let mut any = false
    for i, state in dfa.states {
      let symbols = state.edges.keys().collect()
      symbols.sort()
      for symbol in symbols {
        let target = state.edges[symbol]
        output.write_string(
          state.label(i) +
          "-" +
          grammar.token_name(symbol) +
          "->" +
          dfa.states[target].label(target) +
          "\n",
        )
        any = true
      }
    }
    if !any {
      output.write_string("null")
    }
  }
  output.to_string()
}

///|
priv struct AdaptiveConfig {
  state : Int32
  alt : Int32
  context : Int32
  predicates : Array[(Int32, Int32, Bool)]
  depth : Int32
  collect : Bool
  outside : Bool
}

///|
fn AdaptiveConfig::semantic_key(self : AdaptiveConfig) -> String {
  self.predicates.map(p => "\{p.0}:\{p.1}:\{p.2}").join("/")
}

///|
fn AdaptiveConfig::key(self : AdaptiveConfig) -> String {
  "\{self.state}:\{self.alt}:\{self.context}:\{self.collect}:\{self.depth}:\{self.outside}:" +
  self.semantic_key()
}

///|
fn adaptive_alternatives(configs : Array[AdaptiveConfig]) -> Array[Int32] {
  let result : Array[Int32] = []
  for cfg in configs {
    if !result.contains(cfg.alt) {
      result.push(cfg.alt)
    }
  }
  result.sort()
  result
}

///|
/// Merge contexts per (state, alternative, semantic condition) before grouping
/// conflicting subsets. SLL's empty context is a wildcard; LL's is concrete.
fn adaptive_subsets(
  configs : Array[AdaptiveConfig],
  full : Bool,
) -> Array[Array[Int32]] {
  let merged : Map[(Int32, Int32, String), Array[Int32]] = Map([])
  for cfg in configs {
    let contexts = merged.get_or_init(
      (cfg.state, cfg.alt, cfg.semantic_key()),
      () => [],
    )
    if !contexts.contains(cfg.context) {
      contexts.push(cfg.context)
    }
  }
  let subsets : Map[(Int32, String), Array[Int32]] = Map([])
  for (state, alt, _), contexts in merged {
    contexts.sort()
    let key = if !full && contexts.contains(0) {
      "0"
    } else {
      contexts.map(c => c.to_string()).join(",")
    }
    let alts = subsets.get_or_init((state, key), () => [])
    if !alts.contains(alt) {
      alts.push(alt)
    }
  }
  let result : Array[Array[Int32]] = []
  for alts in subsets.values() {
    alts.sort()
    result.push(alts)
  }
  result
}

///|
fn adaptive_conflict(configs : Array[AdaptiveConfig]) -> Bool {
  let states : Map[Int32, Array[Int32]] = Map([])
  for cfg in configs {
    let alts = states.get_or_init(cfg.state, () => [])
    if !alts.contains(cfg.alt) {
      alts.push(cfg.alt)
    }
  }
  adaptive_subsets(configs, false).any(alts => alts.length() > 1) &&
  !states.values().any(alts => alts.length() == 1)
}

///|
fn Predictor::adaptive_test(
  self : Predictor,
  predicates : Array[(Int32, Int32, Bool)],
  precedence : Int32,
) -> Bool raise RuntimeError {
  for (rule, index, dependent) in predicates {
    if rule == -1 {
      if index < precedence {
        return false
      }
    } else if self.check is Some(check) && !check(rule, index, dependent) {
      return false
    }
  }
  true
}

///|
fn Predictor::adaptive_closure(
  self : Predictor,
  seeds : Array[AdaptiveConfig],
  full : Bool,
  precedence : Int32,
  eof : Bool,
) -> Array[AdaptiveConfig] raise RuntimeError {
  let work = seeds.copy()
  let seen : Map[String, Bool] = Map([])
  let result : Array[AdaptiveConfig] = []
  while work.pop() is Some(cfg) {
    self.budget.tick()
    if seen.contains(cfg.key()) {
      continue
    }
    seen[cfg.key()] = true
    let state = self.atn.states[cfg.state]
    if state.kind == 7 {
      if cfg.context != 0 {
        let ret = self.returns[cfg.context]
        work.push({
          ..cfg,
          state: ret.state,
          context: ret.parent,
          depth: (cfg.depth - 1).max(-1),
        })
      } else if full || self.follows[state.rule].is_empty() {
        result.push(cfg)
      } else {
        for follow in self.follows[state.rule] {
          work.push({ ..cfg, state: follow, outside: true, depth: -1, })
        }
      }
      continue
    }
    if state.edges.is_empty() ||
      state.edges.any(edge => {
        edge.kind == 2 ||
        edge.kind == 5 ||
        edge.kind == 7 ||
        edge.kind == 8 ||
        edge.kind == 9
      }) {
      result.push(cfg)
    }
    for edge in state.edges {
      match edge.kind {
        1 => work.push({ ..cfg, state: edge.target, })
        6 => work.push({ ..cfg, state: edge.target, collect: false, })
        3 =>
          work.push({
            ..cfg,
            state: edge.a,
            context: self.push(edge.target, precedence, cfg.context),
            depth: if cfg.depth < 0 {
              -1
            } else {
              cfg.depth + 1
            },
          })
        4 | 10 =>
          if cfg.collect && (edge.kind == 10 || edge.c == 0 || cfg.depth == 0) {
            let predicate = if edge.kind == 10 {
              (-1, edge.a, false)
            } else {
              (edge.a, edge.b, edge.c != 0)
            }
            if edge.kind == 10 && cfg.depth != 0 {
              work.push({ ..cfg, state: edge.target, })
              continue
            }
            if full {
              if self.adaptive_test([predicate], precedence) {
                work.push({ ..cfg, state: edge.target, })
              }
            } else {
              let predicates = cfg.predicates.copy()
              if !predicates.contains(predicate) {
                predicates.push(predicate)
              }
              work.push({ ..cfg, state: edge.target, predicates, })
            }
          } else {
            work.push({ ..cfg, state: edge.target, })
          }
        2 | 5 | 7 | 8 | 9 =>
          if eof && self.atn.matches(edge, -1) {
            work.push({ ..cfg, state: edge.target, })
          }
        _ => raise Unsupported("adaptive prediction transition")
      }
    }
  }
  result
}

///|
fn Predictor::adaptive_start(
  self : Predictor,
  state : Int32,
  context : Int32,
  full : Bool,
  precedence : Int32,
) -> Array[AdaptiveConfig] raise RuntimeError {
  let seeds : Array[AdaptiveConfig] = []
  for alt, edge in self.atn.states[state].edges {
    seeds.push({
      state: edge.target,
      alt,
      context,
      predicates: [],
      depth: 0,
      collect: true,
      outside: false,
    })
  }
  self.adaptive_closure(seeds, full, precedence, false)
}

///|
fn Predictor::adaptive_reach(
  self : Predictor,
  configs : Array[AdaptiveConfig],
  token : Int32,
  full : Bool,
  precedence : Int32,
) -> Array[AdaptiveConfig] raise RuntimeError {
  let skipped : Array[AdaptiveConfig] = []
  let intermediate : Array[AdaptiveConfig] = []
  for cfg in configs {
    self.budget.tick()
    if self.atn.states[cfg.state].kind == 7 {
      if full || token == -1 {
        skipped.push(cfg)
      }
      continue
    }
    for edge in self.atn.states[cfg.state].edges {
      if self.atn.matches(edge, token) {
        intermediate.push({
          ..cfg,
          state: edge.target,
          collect: false,
          depth: 0,
        })
      }
    }
  }
  let mut reach = if skipped.is_empty() &&
    token != -1 &&
    adaptive_alternatives(intermediate).length() == 1 {
    intermediate
  } else {
    self.adaptive_closure(intermediate, full, precedence, token == -1)
  }
  if token == -1 {
    reach = reach.filter(cfg => self.atn.states[cfg.state].kind == 7)
  }
  if !skipped.is_empty() &&
    (!full || !reach.any(cfg => self.atn.states[cfg.state].kind == 7)) {
    for cfg in skipped {
      reach.push(cfg)
    }
  }
  reach
}

///|
fn Predictor::adaptive_report(
  self : Predictor,
  kind : String,
  decision : Int32,
  input : ParserInput,
  start : Int32,
  stop : Int32,
  alts : Array[Int32],
  exact~ : Bool = false,
  prediction~ : Int32 = 0,
) -> Unit raise RuntimeError {
  self.events.push({
    kind,
    decision,
    start: input.token(start).start,
    stop: input.token(stop).start,
    exact,
    alternatives: alts.map(alt => alt + 1),
    prediction,
  })
}

///|
fn Predictor::adaptive_finished(
  self : Predictor,
  configs : Array[AdaptiveConfig],
  precedence : Int32,
) -> Array[Int32] raise RuntimeError {
  let finished : Array[Int32] = []
  for cfg in configs {
    if (cfg.outside || self.atn.states[cfg.state].kind == 7) &&
      self.adaptive_test(cfg.predicates, precedence) &&
      !finished.contains(cfg.alt) {
      finished.push(cfg.alt)
    }
  }
  finished.sort()
  if finished.is_empty() {
    []
  } else {
    [finished[0]]
  }
}

///|
fn Predictor::adaptive_predict(
  self : Predictor,
  state : Int32,
  precedence : Int32,
  context : Int32,
  input : ParserInput,
  pos : Int32,
) -> Array[Int32] raise RuntimeError {
  self.decisions += 1
  self.failure_pos = pos
  let mut decision = -1
  for i, candidate in self.atn.decisions {
    if candidate == state {
      decision = i
    }
  }
  let mut configs = self.adaptive_start(state, 0, false, precedence)
  let graph = self.adaptive_dfas.get_or_init(decision, () => {
    states: [],
    interned: Map([]),
  })
  let mut graph_state = graph.intern(configs, false, false)
  let mut scan = pos
  while true {
    let token = input.token(scan)
    self.max_lookahead = self.max_lookahead.max(scan - pos + 1)
    let reach = self.adaptive_reach(configs, token.kind, false, precedence)
    if reach.is_empty() {
      self.failure_pos = scan
      return self.adaptive_finished(configs, precedence)
    }
    let alts = adaptive_alternatives(reach)
    let conflict = reach.all(cfg => self.atn.states[cfg.state].kind == 7) ||
      adaptive_conflict(reach)
    let graph_target = graph.intern(
      reach,
      alts.length() == 1 || conflict,
      conflict,
    )
    graph.states[graph_state].edges[token.kind] = graph_target
    graph_state = graph_target
    if alts.length() == 1 || conflict {
      let viable : Array[Int32] = []
      for cfg in reach {
        if !viable.contains(cfg.alt) &&
          self.adaptive_test(cfg.predicates, precedence) {
          viable.push(cfg.alt)
        }
      }
      viable.sort()
      if viable.length() <= 1 {
        return viable
      }
      if self.mode is SLL {
        if reach.any(cfg => !cfg.predicates.is_empty()) {
          self.adaptive_report("ambiguity", decision, input, pos, scan, viable)
        }
        return [viable[0]]
      }
      self.fallbacks += 1
      self.adaptive_report(
        "attempting_full_context", decision, input, pos, scan, viable,
      )
      return self.adaptive_full(
        state, precedence, context, input, pos, decision,
      )
    }
    configs = reach
    if token.kind != -1 {
      scan += 1
    }
  } nobreak {
    []
  }
}

///|
fn Predictor::adaptive_full(
  self : Predictor,
  state : Int32,
  precedence : Int32,
  context : Int32,
  input : ParserInput,
  pos : Int32,
  decision : Int32,
) -> Array[Int32] raise RuntimeError {
  let mut configs = self.adaptive_start(state, context, true, precedence)
  let mut scan = pos
  while true {
    let token = input.token(scan)
    let reach = self.adaptive_reach(configs, token.kind, true, precedence)
    if reach.is_empty() {
      self.failure_pos = scan
      return self.adaptive_finished(configs, precedence)
    }
    let alts = adaptive_alternatives(reach)
    if alts.length() == 1 {
      self.adaptive_report(
        "context_sensitivity",
        decision,
        input,
        pos,
        scan,
        [],
        prediction=alts[0] + 1,
      )
      return alts
    }
    let subsets = adaptive_subsets(reach, true)
    let minima = subsets.map(alts => alts[0])
    let same_min = !minima.is_empty() && minima.all(alt => alt == minima[0])
    let exact = !subsets.is_empty() &&
      subsets.all(alts => alts.length() > 1 && alts == subsets[0])
    if (self.mode is LL && same_min) ||
      (self.mode is LL_EXACT_AMBIG_DETECTION && exact) {
      self.adaptive_report(
        "ambiguity",
        decision,
        input,
        pos,
        scan,
        alts,
        exact=exact && self.mode is LL_EXACT_AMBIG_DETECTION,
      )
      return [alts[0]]
    }
    configs = reach
    if token.kind != -1 {
      scan += 1
    }
    self.max_lookahead = self.max_lookahead.max(scan - pos + 1)
  } nobreak {
    []
  }
}
