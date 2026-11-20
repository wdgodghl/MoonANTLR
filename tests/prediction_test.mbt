///|
test "SLL conflicts use caller returns and share interned DFA transitions" {
  let report = @decisions.grammar().parse_detailed(
    "p a x; q a x y; p a x x; p a x; q a y; u;",
  )
  assert_true(report.prediction.decisions > 0)
  assert_true(report.prediction.full_context_fallbacks > 0)
  assert_true(report.prediction.dfa_states > 0)
  assert_true(report.prediction.dfa_hits > 0)
  let items = report.context.rules("item")
  let short = items[0].rules("choice")[0]
  let long = items[1].rules("choice")[0]
  assert_eq(short.text(), "a")
  assert_eq(long.text(), "ax")
  assert_eq(
    @decisions.DecisionsParser::new().parse_choice("a").alternative(),
    Some("Short"),
  )
  assert_eq(
    @decisions.DecisionsParser::new().parse_choice("a x").alternative(),
    Some("Long"),
  )
}

///|
test "prediction follows a common prefix beyond 64 tokens" {
  let words : Array[String] = []
  for _ in 0..<90 {
    words.push("foo ")
  }
  let input = "z " + words.join("") + "?;"
  let result = @decisions.grammar().parse_detailed(input)
  assert_true(result.prediction.max_lookahead > 64)
  assert_eq(
    result.context.rules("item")[0].rules("longChoice")[0]
    .text()
    .has_suffix("?"),
    true,
  )
}

///|
test "ambiguous complete parses select the first grammar alternative" {
  let context = @decisions.grammar().parse_context("u;")
  let either = context.rules("item")[0].rules("either")[0]
  assert_eq(either.rules("first").length(), 1)
  assert_true(either.rules("second").is_empty())
}

///|
test "generated Lexer predicates receive an absolute scalar offset and isolate calls" {
  let lexer = @lexgate.LexGateLexer::new()
  let enabled = lexer.tokenize("if\nif", lexer_predicate=(_, _, offset, _) => {
    offset == 2
  })
  let disabled = lexer.tokenize("if\nif", lexer_predicate=(_, _, _, _) => false)
  assert_eq(enabled[0].text, "if")
  assert_true(enabled[0].kind != disabled[0].kind)
  assert_eq(enabled[1].kind, disabled[1].kind)
  assert_eq(enabled[1].line, 2)
  let rejected = try {
    let _ = lexer.tokenize("if")
    false
  } catch {
    @runtime.Unsupported("semantic predicates") => true
    _ => false
  }
  assert_true(rejected)
  let parser = @lexgate.LexGateParser::new()
  let document = parser.parse_document("if", lexer_predicate=(_, _, _, _) => {
    true
  })
  assert_eq(document.raw().tokens(enabled[0].kind).length(), 1)
}

///|
test "empty rule contexts and filtered channels keep useful spans" {
  let context = @modes.grammar().parse_context("")
  assert_eq(context.span(), None)
  assert_eq(context.text(), "")
}
