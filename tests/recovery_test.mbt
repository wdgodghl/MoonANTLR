///|
test "recovery inserts a missing separator and keeps the following value" {
  let result = @json.grammar().parse_recovering("[1 2]")
  assert_true(result.complete)
  assert_eq(result.diagnostics.length(), 1)
  assert_eq(result.diagnostics[0].column, Some(3))
  assert_true(
    result.repairs[0] is @runtime.Inserted(token) &&
    token.start == 3 &&
    token.end == 3,
  )
  assert_true(result.context.unwrap().to_tree().to_sexpr().contains("\"2\""))
}

///|
test "recovery deletes an extra token and respects the repair limit" {
  let grammar = @json.grammar()
  let repaired = grammar.parse_recovering("[1,,2]")
  assert_true(repaired.complete)
  assert_eq(repaired.diagnostics[0].column, Some(3))
  assert_true(
    repaired.repairs[0] is @runtime.Deleted(token) && token.text == ",",
  )
  assert_eq(repaired.context.unwrap().text(), "[1,2]")
  let strict = grammar.parse_recovering("[1,,2]", max_repairs=0)
  assert_false(strict.complete)
  assert_eq(strict.diagnostics.length(), 1)
}

///|
test "recovery returns the available prefix when repair is disabled" {
  let result = @typed.grammar().parse_recovering("x=1; = = ;", max_repairs=0)
  assert_false(result.complete)
  assert_eq(result.context.unwrap().rules("entry")[0].text(), "x=1")
}

///|
test "recovery synchronizes past a broken statement and keeps the next entry" {
  let grammar = @typed.grammar()
  let separator = grammar.tokenize(";")[0].kind
  let result = grammar.parse_recovering(
    "x=1; = = = ; y=2",
    sync_tokens=[separator],
    max_repairs=1,
  )
  assert_true(result.complete)
  assert_eq(result.diagnostics[0].column, Some(5))
  assert_true(
    result.repairs[0] is @runtime.Synchronized(tokens) && tokens.length() == 4,
  )
  let entries = result.context.unwrap().rules("entry")
  assert_eq(entries.length(), 2)
  assert_eq(entries[1].text(), "y=2")
}

///|
test "generated predicate binding uses the current token and is isolated across calls" {
  let parser = @predicate.PredicateParser::new()
  let enabled = parser.parse_document("123", predicate=(rule, _, token) => {
    rule == 1 && token.text == "123"
  })
  let fallback = parser.parse_document("123", predicate=(_, _, _) => false)
  assert_eq(enabled.raw().rules("enabled").length(), 1)
  assert_eq(fallback.raw().rules("fallback").length(), 1)
}

///|
test "parser recovery can continue after an opt-in lexer error" {
  let grammar = @json.grammar()
  let result = grammar.parse_recovering("[1,💥2]", recover_lexer=true)
  assert_true(result.complete)
  assert_eq(result.diagnostics[0].code, "lexical_error")
  assert_eq(result.diagnostics[0].column, Some(3))
  assert_eq(result.context.unwrap().text(), "[1,2]")
  let strict = try {
    let _ = grammar.parse_recovering("[1,💥2]")
    false
  } catch {
    @runtime.LexicalError(_, _, _) => true
    _ => false
  }
  assert_true(strict)
}

///|
test "generated parser forwards committed lexer actions" {
  let offsets : Array[Int32] = []
  let parser = @lexactions.LexActionsParser::new()
  let context = parser.parse_document("xyz", lexer_action=(event, _) => {
    offsets.push(event.offset)
  })
  @debug.assert_eq(offsets, [2, 3])
  assert_eq(context.raw().text(), "xyz")
}

///|
test "a rejected strict parse cannot call a parser action" {
  let calls : Array[Int32] = []
  let parser = @parseactions.ParseActionsParser::new()
  let rejected = try {
    let _ = parser.parse_document("a", parser_action=event => {
      calls.push(event.action)
    })
    false
  } catch {
    @runtime.SyntaxError(_, _, _) => true
    _ => false
  }
  assert_true(rejected)
  assert_true(calls.is_empty())
}
