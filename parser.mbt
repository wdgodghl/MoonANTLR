///|
priv struct Outcome {
  pos : Int32
  context : RuleContext
}

///|
priv struct ParseConfig {
  state : Int32
  pos : Int32
  context : RuleContext
  visited : Array[(Int32, Int32)]
}

///|
priv struct ParseContext {
  mut predicting : Bool
  atn : Atn
  rules : Array[String]
  tokens : Array[Token]
  predictor : Predictor
  budget : Budget
  cache : Map[(Int32, Int32, Int32, Int32), Array[Outcome]]
  active : Map[(Int32, Int32, Int32, Int32), Bool]
  mut furthest : Int32
  expected : Map[Int32, Bool]
}

///|
fn ParseContext::expect(self : ParseContext, pos : Int32, edge : Edge) -> Unit {
  if pos > self.furthest {
    self.furthest = pos
    self.expected.clear()
  }
  if pos != self.furthest {
    return
  }
  if edge.kind == 5 {
    self.expected[if edge.c != 0 { -1 } else { edge.a }] = true
  } else {
    for symbol in 1..<=self.atn.max_token {
      if self.atn.matches(edge, symbol) {
        self.expected[symbol] = true
      }
    }
    if self.atn.matches(edge, -1) {
      self.expected[-1] = true
    }
  }
}

///| Ordered bounded traversal with rule/position memoization. This is an

///|
/// Precedence is part of the memoization key, including right-associative calls.
fn parse_rule(
  ctx : ParseContext,
  rule : Int32,
  pos : Int32,
  depth : Int32,
  precedence : Int32,
  outer : Int32,
) -> Array[Outcome] raise RuntimeError {
  if depth > 128 {
    raise LimitExceeded("parser rule nesting exceeds 128")
  }
  let key = (rule, pos, precedence, outer)
  match ctx.cache.get(key) {
    Some(cached) => return cached
    None => ()
  }
  if ctx.active.get(key).unwrap_or(false) {
    raise Unsupported("left-recursive rule invocation")
  }
  ctx.active[key] = true
  let work : Array[ParseConfig] = [
    {
      state: ctx.atn.starts[rule],
      pos,
      context: { name: ctx.rules[rule], children: [], sources: [], path: [], },
      visited: [],
    },
  ]
  let results : Array[Outcome] = []
  while work.length() > 0 {
    ctx.budget.tick()
    let cfg = work.pop().unwrap()
    let state = ctx.atn.states[cfg.state]
    let cfg = { ..cfg, context: cfg.context.enter(cfg.state), }
    if state.kind == 7 {
      results.push({ pos: cfg.pos, context: cfg.context, })
      continue
    }
    let stamp = (cfg.state, cfg.pos)
    if cfg.visited.contains(stamp) {
      continue
    }
    let visited = cfg.visited.copy()
    visited.push(stamp)
    let predicted = if ctx.predicting && state.edges.length() > 1 {
      ctx.predictor.predict(cfg.state, precedence, outer, ctx.tokens, cfg.pos)
    } else {
      []
    }
    // The worklist is LIFO: reverse pushes preserve grammar alternative order.
    for i = state.edges.length() - 1; i >= 0; i = i - 1 {
      if !predicted.is_empty() && !predicted.contains(i) {
        continue
      }
      let edge = state.edges[i]
      match edge.kind {
        1 => {
          let context = if ctx.atn.is_precedence_decision(cfg.state) &&
            ctx.atn.states[edge.target].kind != 12 {
            {
              name: ctx.rules[rule],
              children: [RuleChild(cfg.context)],
              sources: [-1],
              path: [],
            }
          } else {
            cfg.context
          }
          work.push({ ..cfg, state: edge.target, context, visited, })
        }
        6 => work.push({ ..cfg, state: edge.target, visited, })
        10 =>
          if edge.a >= precedence {
            work.push({ ..cfg, state: edge.target, visited, })
          }
        3 => {
          let outer = ctx.predictor.push(edge.target, precedence, outer)
          let outcomes = parse_rule(
            ctx,
            edge.b,
            cfg.pos,
            depth + 1,
            edge.c,
            outer,
          )
          for j = outcomes.length() - 1; j >= 0; j = j - 1 {
            let outcome = outcomes[j]
            let context = cfg.context.append(
              RuleChild(outcome.context),
              cfg.state,
            )
            work.push({
              state: edge.target,
              pos: outcome.pos,
              context,
              visited,
            })
          }
        }
        2 | 5 | 7 | 8 | 9 =>
          if cfg.pos < ctx.tokens.length() &&
            ctx.atn.matches(edge, ctx.tokens[cfg.pos].kind) {
            let context = cfg.context.append(
              TokenChild(ctx.tokens[cfg.pos]),
              cfg.state,
            )
            work.push({
              state: edge.target,
              pos: cfg.pos + 1,
              context,
              visited: [],
            })
          } else {
            ctx.expect(cfg.pos, edge)
          }
        _ => raise Unsupported("unsupported parser transition")
      }
    }
  }
  ctx.active[key] = false
  ctx.cache[key] = results
  results
}

///| Parse a complete document using a rule index (default: first grammar rule).

///|
/// Non-default channels are filtered, and trailing input is always rejected.
pub fn Grammar::parse_detailed(
  self : Grammar,
  source : String,
  start_rule~ : Int32 = 0,
  work_limit~ : Int32 = 1_000_000,
) -> ParseResult raise RuntimeError {
  if self.parser.kind != 1 {
    raise InvalidAtn("parser ATN expected")
  }
  self.parser.validate_supported()
  if self.rules.length() != self.parser.starts.length() {
    raise InvalidAtn("rule-name table length mismatch")
  }
  if start_rule < 0 || start_rule >= self.rules.length() {
    raise InvalidAtn("unknown start rule")
  }
  let tokens = TokenStream::new(self.tokenize(source, work_limit~)).visible_tokens()
  let budget : Budget = { remaining: work_limit, }
  let predictor = Predictor::new(self.parser, budget)
  let ctx : ParseContext = {
    predicting: true,
    predictor,
    atn: self.parser,
    rules: self.rules,
    tokens,
    budget,
    cache: Map([]),
    active: Map([]),
    furthest: 0,
    expected: Map([]),
  }
  let outcomes = parse_rule(ctx, start_rule, 0, 0, 0, 0)
  // Revisit rejected input without pruning so expected-token diagnostics still
  // refer to the furthest syntactic failure, not an earlier prediction exit.
  let outcomes = if outcomes.any(outcome => outcome.pos >= tokens.length() - 1) {
    outcomes
  } else {
    ctx.predicting = false
    ctx.cache.clear()
    ctx.active.clear()
    parse_rule(ctx, start_rule, 0, 0, 0, 0)
  }
  for outcome in outcomes {
    if outcome.pos == tokens.length() || outcome.pos == tokens.length() - 1 {
      return {
        context: outcome.context,
        prediction: {
          decisions: predictor.decisions,
          full_context_fallbacks: predictor.fallbacks,
          dfa_states: predictor.states.length(),
          dfa_hits: predictor.hits,
        },
      }
    }
    ctx.expect(outcome.pos, { target: 0, kind: 5, a: 0, b: 0, c: 1, })
  }
  let expected : Array[Int32] = ctx.expected.keys().collect()
  expected.sort()
  let index = ctx.furthest.min(tokens.length() - 1)
  raise SyntaxError(tokens[index].line, tokens[index].column, expected)
}

///|
/// Parse and return the lightweight, backwards-compatible tree representation.
pub fn Grammar::parse(
  self : Grammar,
  source : String,
  start_rule~ : Int32 = 0,
  work_limit~ : Int32 = 1_000_000,
) -> ParseTree raise RuntimeError {
  self.parse_context(source, start_rule~, work_limit~).to_tree()
}

///|
/// Parse with concrete rule and element source identities.
pub fn Grammar::parse_context(
  self : Grammar,
  source : String,
  start_rule~ : Int32 = 0,
  work_limit~ : Int32 = 1_000_000,
) -> RuleContext raise RuntimeError {
  self.parse_detailed(source, start_rule~, work_limit~).context
}
