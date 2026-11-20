///|
test "cursor does not execute actions or encounter errors beyond demand" {
  let offsets : Array[Int32] = []
  let cursor = @lexactions.grammar().lexer_cursor("xyz xyz 💥", lexer_action=(
    event,
    _,
  ) => offsets.push(event.offset))
  assert_true(offsets.is_empty())
  assert_eq(cursor.next_token().text, "xyz")
  @debug.assert_eq(offsets, [2, 3])
  assert_true(cursor.diagnostics().is_empty())
  assert_eq(cursor.next_token().text, "xyz")
  @debug.assert_eq(offsets, [2, 3, 4, 6, 7])
  let failed = try {
    let _ = cursor.next_token()
    false
  } catch {
    @runtime.LexicalError(1, 8, _) => true
    _ => false
  }
  assert_true(failed)
}

///|
test "cursor recovery reports errors only when the next token is requested" {
  let cursor = @json.grammar().lexer_cursor("1 💥 2", recover=true)
  assert_eq(cursor.next_token().text, "1")
  assert_true(cursor.diagnostics().is_empty())
  assert_eq(cursor.next_token().text, "2")
  assert_eq(cursor.diagnostics().length(), 1)
  let copy = cursor.diagnostics()
  copy.clear()
  assert_eq(cursor.diagnostics().length(), 1)
  let eof = cursor.next_token()
  assert_eq(eof.kind, -1)
  assert_true(cursor.next_token() == eof)
}

///|
test "cursor retains mode and more state and does not replay EOF actions" {
  let actions : Array[Int32] = []
  let cursor = @stateful.grammar().lexer_cursor("\"😀\"#unread", lexer_action=(
    event,
    _,
  ) => {
    actions.push(event.rule)
    match event.rule {
      0 => {
        event.emission = @runtime.More
        event.push_mode(1)
      }
      1 => event.emission = @runtime.Emit(-1)
      4 => {
        event.pop_mode()
        event.emission = @runtime.Emit(1)
      }
      _ => ()
    }
  })
  let token = cursor.next_token()
  assert_eq(token.text, "\"😀\"")
  assert_eq(token.end, 3)
  @debug.assert_eq(actions, [0, 4])
  let eof = cursor.next_token()
  assert_eq(eof.kind, -1)
  assert_eq(eof.text, "#")
  assert_true(cursor.next_token() == eof)
  @debug.assert_eq(actions, [0, 4, 1])
}

///|
test "lazy prefix prefetches the next visible token but leaves later actions untouched" {
  let offsets : Array[Int32] = []
  let result = @lexactions.grammar().parse_prefix_lazy(
    "xyz xyz xyz",
    start_rule=1,
    lexer_action=(event, _) => offsets.push(event.offset),
  )
  assert_eq(result.parsed.context.text(), "xyz")
  assert_eq(result.next_token.text, "xyz")
  @debug.assert_eq(offsets, [2, 3, 4, 6, 7])
}
