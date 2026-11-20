///|
test "valid nesting beyond the former fixed parser depth remains budget bounded" {
  let source = String::from_array(Array::make(70, '[')) +
    "0" +
    String::from_array(Array::make(70, ']'))
  let grammar = @json.grammar()
  assert_eq(grammar.parse_context(source).text(), source)
  let recovered = grammar.parse_default(source)
  assert_true(recovered.diagnostics.is_empty())
  assert_eq(recovered.context.text(), source)
  let limited = try {
    let _ = grammar.parse_default(source, work_limit=10)
    false
  } catch {
    @runtime.LimitExceeded(_) => true
    _ => false
  }
  assert_true(limited)
}
