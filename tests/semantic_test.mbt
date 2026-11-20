///|
fn attribute_int(frame : @runtime.RuleFrame, name : String) -> Int32 {
  match frame.values.get(name) {
    Some(Number(value, ..)) => value.to_int()
    _ => abort("missing integer attribute")
  }
}

///|
fn attribute_bindings() -> @runtime.RuleSemantics {
  {
    enter: (_, frame) => {
      frame.values["seen"] = Json::number(0)
      frame
    },
    arguments: (event, _) => {
      let mut value = 0
      for (site, expression) in @attributes.argument_expressions() {
        if site == event.site {
          value = expression
            .to_array()
            .fold(init=0, (n, c) => n * 10 + c.to_int() - 48)
        }
      }
      Map([("seed", Json::number(value.to_double()))])
    },
    action: (event, _) => {
      let values = event.frame.values
      if event.rule == 0 {
        let children = event.frame.children
        values["total"] = Json::number(
          (attribute_int(children[0], "value") +
          attribute_int(children[1], "value")).to_double(),
        )
      } else {
        let value = event.context.tokens(1)[0].text
          .to_array()
          .fold(init=0, (n, c) => n * 10 + c.to_int() - 48)
        values["seen"] = Json::number(1)
        values["value"] = Json::number(
          (attribute_int(event.frame, "seed") + value).to_double(),
        )
      }
      event.frame
    },
    predicate: (event, _) => attribute_int(event.frame, "value") > 0,
  }
}

///|
test "an action's value is visible to its following context-dependent predicate" {
  let result = @attributes.grammar().parse_semantic("2 3", attribute_bindings())
  assert_eq(attribute_int(result.frame.unwrap(), "total"), 16)
  let rejected = try {
    let _ = @attributes.grammar().parse_semantic(
      "2",
      attribute_bindings(),
      start_rule=1,
      arguments=Map([("seed", Json::number(-3))]),
    )
    false
  } catch {
    @runtime.SyntaxError(_, _, _) => true
    _ => false
  }
  assert_true(rejected)
}

///|
test "semantic frames isolate attributes, shared updates, and alternative speculation" {
  let input_shared = Map([("calls", Json::number(0))])
  let bindings = {
    ..@runtime.RuleSemantics::new(),
    action: (event, _) => {
      let count = match event.frame.shared.get("calls") {
        Some(Number(value, ..)) => value.to_int()
        _ => 0
      }
      event.frame.shared["calls"] = Json::number((count + 1).to_double())
      event.frame
    },
  }
  let grammar = @parseactions.grammar()
  let accepted = grammar.parse_semantic("ac", bindings, shared=input_shared).frame.unwrap()
  assert_eq(accepted.shared.get("calls"), Some(Json::number(3)))
  assert_eq(input_shared.get("calls"), Some(Json::number(0)))
  assert_eq(
    grammar.parse_semantic("ab", bindings, shared=input_shared).frame.unwrap().shared.get(
      "calls",
    ),
    Some(Json::number(3)),
  )
  let rejected = try {
    let _ = grammar.parse_semantic("a", bindings, shared=input_shared)
    false
  } catch {
    @runtime.SyntaxError(_, _, _) => true
    _ => false
  }
  assert_true(rejected)
  assert_eq(input_shared.get("calls"), Some(Json::number(0)))
}

///|
test "generated attribute declarations retain arguments returns and locals" {
  let declarations = @attributes.attribute_declarations()
  assert_eq(declarations.length(), 4)
  assert_eq(declarations[1], (1, "argument", "seed", "int", ""))
  assert_eq(declarations[3], (1, "local", "seen", "int", ""))
}
