///|
priv struct Outcome {
  pos : Int32
  tree : ParseTree
}

///|
priv struct ParseConfig {
  state : Int32
  pos : Int32
  children : Array[ParseTree]
  visited : Array[(Int32, Int32)]
}

///|
priv struct ParseContext {
  atn : Atn
  rules : Array[String]
  tokens : Array[Token]
  budget : Budget
  cache : Map[(Int32, Int32), Array[Outcome]]
  active : Map[(Int32, Int32), Bool]
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
/// action-free ATN interpreter, not ANTLR's adaptive LL(*) predictor.
fn parse_rule(
  ctx : ParseContext,
  rule : Int32,
  pos : Int32,
  depth : Int32,
) -> Array[Outcome] raise RuntimeError {
  if depth > 128 {
    raise LimitExceeded("parser rule nesting exceeds 128")
  }
  let key = (rule, pos)
  match ctx.cache.get(key) {
    Some(cached) => return cached
    None => ()
  }
  if ctx.active.get(key).unwrap_or(false) {
    raise Unsupported("left-recursive rule invocation")
  }
  ctx.active[key] = true
  let work : Array[ParseConfig] = [
    { state: ctx.atn.starts[rule], pos, children: [], visited: [], },
  ]
  let results : Array[Outcome] = []
  while work.length() > 0 {
    ctx.budget.tick()
    let cfg = work.pop().unwrap()
    let state = ctx.atn.states[cfg.state]
    if state.kind == 7 {
      results.push({ pos: cfg.pos, tree: Rule(ctx.rules[rule], cfg.children), })
      continue
    }
    let stamp = (cfg.state, cfg.pos)
    if cfg.visited.contains(stamp) {
      continue
    }
    let visited = cfg.visited.copy()
    visited.push(stamp)
    // The worklist is LIFO: reverse pushes preserve grammar alternative order.
    for i = state.edges.length() - 1; i >= 0; i = i - 1 {
      let edge = state.edges[i]
      match edge.kind {
        1 => work.push({ ..cfg, state: edge.target, visited, })
        3 => {
          let outcomes = parse_rule(ctx, edge.b, cfg.pos, depth + 1)
          for j = outcomes.length() - 1; j >= 0; j = j - 1 {
            let outcome = outcomes[j]
            let children = cfg.children.copy()
            children.push(outcome.tree)
            work.push({
              state: edge.target,
              pos: outcome.pos,
              children,
              visited,
            })
          }
        }
        2 | 5 | 7 | 8 | 9 =>
          if cfg.pos < ctx.tokens.length() &&
            ctx.atn.matches(edge, ctx.tokens[cfg.pos].kind) {
            let children = cfg.children.copy()
            children.push(Terminal(ctx.tokens[cfg.pos]))
            work.push({
              state: edge.target,
              pos: cfg.pos + 1,
              children,
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
pub fn Grammar::parse(
  self : Grammar,
  source : String,
  start_rule~ : Int32 = 0,
  work_limit~ : Int32 = 1_000_000,
) -> ParseTree raise RuntimeError {
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
  let ctx : ParseContext = {
    atn: self.parser,
    rules: self.rules,
    tokens,
    budget: { remaining: work_limit, },
    cache: Map([]),
    active: Map([]),
    furthest: 0,
    expected: Map([]),
  }
  let outcomes = parse_rule(ctx, start_rule, 0, 0)
  for outcome in outcomes {
    if outcome.pos == tokens.length() || outcome.pos == tokens.length() - 1 {
      return outcome.tree
    }
    ctx.expect(outcome.pos, { target: 0, kind: 5, a: 0, b: 0, c: 1, })
  }
  let expected : Array[Int32] = ctx.expected.keys().collect()
  expected.sort()
  let index = ctx.furthest.min(tokens.length() - 1)
  raise SyntaxError(tokens[index].line, tokens[index].column, expected)
}
