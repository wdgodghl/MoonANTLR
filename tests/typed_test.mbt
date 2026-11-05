///|
test "generated parser has typed rule entries and positional label captures" {
  let parser = @typed.TypedParser::new()
  let document = parser.parse_document("x=1+2*3; y=2^3^4 note;")
  let entries = document.label_entries()
  assert_eq(entries.length(), 2)
  assert_eq(entries[0].label_key()[0].text, "x")
  assert_true(entries[0].label_note().is_empty())
  assert_eq(entries[1].label_note()[0].text, "note")
  let value = entries[0].label_value()[0]
  assert_eq(value.alternative(), Some("Sum"))
  assert_eq(value.label_left()[0].raw().text(), "1")
  assert_eq(value.label_op()[0].text, "+")
  assert_eq(value.label_right()[0].alternative(), Some("Product"))
  assert_eq(value.raw().span(), Some((2, 7)))
  assert_true(value.as_Sum() is Some(_))
  assert_true(value.as_Number() is None)
  let power = entries[1].label_value()[0]
  assert_eq(power.alternative(), Some("Power"))
  assert_eq(power.label_right()[0].alternative(), Some("Power"))
  assert_eq(parser.parse_expression("(12)").alternative(), Some("Group"))
  assert_eq(@typed.TypedLexer::new().tokenize("abc=12")[0].text, "abc")
}

///|
test "generated visitor evaluates expressions without tree string matching" {
  let base : @typed.TypedVisitor[Int32] = @typed.TypedVisitor::new(
    terminal=t => if t.kind == -1 { 0 } else { 1 },
    rule=(_, children) => children.fold(init=0, (a, b) => a + b),
  )
  let visitor = {
    ..base,
    visit_expression: (context, values) => {
      match context.alternative() {
        Some("Number") =>
          context.label_number()[0].text
          .to_array()
          .fold(init=0, (n, c) => n * 10 + c.to_int() - 48)
        Some("Group") => values[1]
        Some("Product") => values[0] * values[2]
        Some("Sum") => values[0] + values[2]
        _ => 0
      }
    },
  }
  let context = @typed.TypedParser::new().parse_expression("(1+2)*3")
  assert_eq(visitor.visit(context.raw()), 9)
}

///|
test "generated listener walks nested rules in enter terminal exit order" {
  let events : Array[String] = []
  let listener = {
    ..@typed.TypedListener::new(),
    enter_expression: context => events.push("+" + context.raw().text()),
    exit_expression: context => events.push("-" + context.raw().text()),
    terminal: token => events.push(token.text),
  }
  listener.walk(@typed.TypedParser::new().parse_expression("1+2").raw())
  @debug.assert_eq(events, [
    "+1+2", "+1", "1", "-1", "+", "+2", "2", "-2", "-1+2",
  ])
}

///|
test "alternative visitor overrides fall back to the rule visitor" {
  let base : @typed.TypedVisitor[Int32] = @typed.TypedVisitor::new(
    terminal=_ => 0,
    rule=(_, children) => children.fold(init=0, (a, b) => a + b),
  )
  let visitor = { ..base, visit_alt_Number: Some((_, _) => 1), }
  let context = @typed.TypedParser::new().parse_expression("1+(2*3)")
  assert_eq(visitor.visit(context.raw()), 3)
  let events : Array[String] = []
  let listener = {
    ..@typed.TypedListener::new(),
    enter_alt_Sum: _ => events.push("+sum"),
    exit_alt_Sum: _ => events.push("-sum"),
    enter_alt_Number: _ => events.push("number"),
  }
  listener.walk(context.raw())
  @debug.assert_eq(events, ["+sum", "number", "number", "number", "-sum"])
}
