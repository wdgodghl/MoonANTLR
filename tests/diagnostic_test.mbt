///|
test "syntax errors retain locations and name literal tokens" {
  let grammar = @json.grammar()
  let diagnostic = try {
    let _ = grammar.parse("{\"x\" 1}")
    None
  } catch {
    error => Some(error.diagnostic(grammar))
  }
  let d = diagnostic.unwrap()
  assert_eq(d.code, "syntax_error")
  assert_eq(d.line, Some(1))
  assert_eq(d.column, Some(5))
  assert_true(d.expected.contains("':'"))
  assert_true(d.to_json().stringify().contains("syntax_error"))
}

///|
test "vocabularies expose symbolic names, EOF and unknown token fallback" {
  let grammar = @json.grammar()
  assert_eq(grammar.token_name(10), "STRING")
  assert_eq(grammar.token_name(-1), "EOF")
  assert_eq(grammar.token_name(999), "999")
  let d = @runtime.LexicalError(2, 4, "unrecognized character").diagnostic(
    grammar,
  )
  assert_eq(d.code, "lexical_error")
  assert_eq(d.line, Some(2))
  assert_eq(
    @runtime.LimitExceeded("budget").diagnostic(grammar).code,
    "limit_exceeded",
  )
}
