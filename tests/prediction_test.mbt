///|
test "SLL conflicts use caller returns and share interned DFA transitions" {
  let report = @decisions.grammar().parse_detailed(
    "p a x; q a x y; p a x x; p a x; q a y;",
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
test "prediction retains alternatives beyond its lookahead window" {
  let words : Array[String] = []
  for _ in 0..<90 {
    words.push("foo ")
  }
  let input = "z " + words.join("") + "?;"
  let result = @decisions.grammar().parse_detailed(input)
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
test "empty rule contexts and filtered channels keep useful spans" {
  let context = @modes.grammar().parse_context("")
  assert_eq(context.span(), None)
  assert_eq(context.text(), "")
}
