///|
fn lifecycle_delta(action : Int32) -> Int32 {
  let source = @lifecycle.parser_action_sources()[action]
  if source.contains("+= 1000;") {
    1000
  } else if source.contains("+= 100;") {
    100
  } else if source.contains("+= 10;") {
    10
  } else {
    1
  }
}

///|
fn lifecycle_bindings() -> @runtime.RuleSemantics {
  {
    ..@runtime.RuleSemantics::new(),
    action: (event, action) => {
      let delta = lifecycle_delta(action)
      let old = match event.frame.values.get("total") {
        Some(Number(n, ..)) => n.to_int()
        _ => 0
      }
      event.frame.values["total"] = Json::number(
        (if delta == 1 { 1 } else { old + delta }).to_double(),
      )
      event.frame
    },
  }
}

///|
test "named lifecycle actions preserve initialization after and finally" {
  let result = @lifecycle.grammar().parse_default(
    "x",
    semantics=lifecycle_bindings(),
  )
  assert_eq(result.frame.unwrap().int_value("total"), Some(1111))
}
