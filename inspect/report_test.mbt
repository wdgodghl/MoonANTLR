///|
test "successful inspection includes a parse tree and tokens" {
  let grammar = @json.grammar()
  let report = @inspect.analyze(grammar, "{\"ready\":true}")
  assert_true(report is { "ok": true, "tree": _, "tokens": _, .. })
}

///|
test "inspection returns source diagnostics for malformed input" {
  let grammar = @json.grammar()
  let report = @inspect.analyze(grammar, "{\"ready\" 1}")
  assert_true(
    report
    is {
      "ok": false,
      "diagnostic": { "code": "syntax_error", "line": 1, .. },
      ..
    },
  )
}
