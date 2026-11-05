///|
test "JSON objects, arrays, literals, escapes and numbers" {
  let grammar = @json.grammar()
  for
    input in [
      "{}", "[]", "null", "true", "false", "123", "-0", "0.125e-3", "\"line\\nquote\\\"\\u1234\"",
      "{\"a\":[1,-2.5e+3,true,false,null,{}]}",
    ] {
    let tree = grammar.parse(input)
    assert_true(tree.to_sexpr().has_prefix("(document "))
    assert_true(tree.to_sexpr().has_suffix("<EOF>)"))
  }
}

///|
test "malformed JSON is rejected, including valid prefixes with trailing input" {
  let grammar = @json.grammar()
  for
    input in [
      "", "{", "[1,]", "{\"x\" 1}", "01", "true false", "\"bad\\x\"", "\"line\n\"",
      "1.", "-", "[true false]",
    ] {
    let rejected = try {
      let _ = grammar.parse(input)
      false
    } catch {
      _ => true
    }
    assert_true(rejected, msg="unexpected acceptance: " + input)
  }
}

///|
test "lexer uses longest match, strips skipped whitespace and preserves positions" {
  let tokens = @json.grammar().tokenize("\n  -12.5e+2 true")
  assert_eq(tokens.length(), 3)
  assert_eq(tokens[0].text, "-12.5e+2")
  assert_eq(tokens[0].line, 2)
  assert_eq(tokens[0].column, 2)
  assert_eq(tokens[0].start, 3)
  assert_eq(tokens[0].end, 11)
  assert_eq(tokens[1].text, "true")
  assert_eq(tokens[2].kind, -1)
}

///|
test "Unicode scalar offsets include supplementary characters" {
  let tokens = @json.grammar().tokenize("\"😀中\" \"x\"")
  assert_eq(tokens[0].text, "\"😀中\"")
  assert_eq(tokens[0].end, 4)
  assert_eq(tokens[1].start, 5)
  assert_eq(tokens[1].column, 5)
}

///|
test "arithmetic grammar preserves precedence and nested rule structure" {
  let grammar = @arithmetic.grammar()
  assert_eq(
    grammar.parse("1+2*3").to_sexpr(),
    "(document (expression (term (factor \"1\")) \"+\" (term (factor \"2\") \"*\" (factor \"3\"))) <EOF>)",
  )
  let _ = grammar.parse("(1+2)*(3-4)/5")
  let rejected = try {
    let _ = grammar.parse("1+*2")
    false
  } catch {
    @runtime.SyntaxError(line, column, _) => line == 1 && column == 2
    _ => false
  }
  assert_true(rejected)
}

///|
test "ATN decoder rejects every truncated parser artifact without aborting" {
  let data = @json.parser_data()
  for end in 0..<data.length() {
    let rejected = try {
      let _ = @runtime.deserialize(data[:end].to_owned())
      false
    } catch {
      @runtime.InvalidAtn(_) => true
      _ => false
    }
    assert_true(rejected)
  }
}

///|
test "ATN decoder rejects bad versions, lengths, types and trailing data" {
  let original = @json.parser_data()
  for (index, value) in [(0, 99), (1, 3), (2, -1), (3, -1), (4, 99)] {
    let data = original.copy()
    data[index] = value
    let rejected = try {
      let _ = @runtime.deserialize(data)
      false
    } catch {
      @runtime.InvalidAtn(_) => true
      _ => false
    }
    assert_true(rejected)
  }
  let data = original.copy()
  data.push(99)
  let rejected = try {
    let _ = @runtime.deserialize(data)
    false
  } catch {
    @runtime.InvalidAtn(_) => true
    _ => false
  }
  assert_true(rejected)
}

///|
test "precedence predicates fail explicitly rather than executing as epsilon" {
  let rejected = try {
    let _ = @precedence.grammar().parse("1+2+3")
    false
  } catch {
    @runtime.Unsupported(feature) => {
      assert_eq(feature, "precedence predicates")
      true
    }
    _ => false
  }
  assert_true(rejected)
}

///|
test "semantic predicates fail explicitly rather than being ignored" {
  let rejected = try {
    let _ = @predicate.grammar().parse("123")
    false
  } catch {
    @runtime.Unsupported(feature) => feature == "semantic predicates"
    _ => false
  }
  assert_true(rejected)
}

///|
test "non-greedy lexer decisions fail explicitly" {
  let rejected = try {
    let _ = @nongreedy.grammar().parse("/* a */")
    false
  } catch {
    @runtime.Unsupported(feature) => feature == "non-greedy lexer decisions"
    _ => false
  }
  assert_true(rejected)
}

///|
test "work limits and unknown start rules produce typed failures" {
  let grammar = @json.grammar()
  let limited = try {
    let _ = grammar.parse("[1,2,3]", work_limit=1)
    false
  } catch {
    @runtime.LimitExceeded(_) => true
    _ => false
  }
  assert_true(limited)
  let invalid = try {
    let _ = grammar.parse("null", start_rule=99)
    false
  } catch {
    @runtime.InvalidAtn(_) => true
    _ => false
  }
  assert_true(invalid)
}
