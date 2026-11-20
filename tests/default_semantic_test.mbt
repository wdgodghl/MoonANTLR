///|
test "default prediction evaluates visible predicates without executing actions" {
  for enabled in [true, false, true] {
    let report = @predicate.grammar().parse_default("123", predicate=(_, _, _) => {
      return enabled
    })
    assert_true(report.diagnostics.is_empty())
    assert_eq(
      report.context
      .rules(if enabled { "enabled" } else { "fallback" })
      .length(),
      1,
    )
  }
}

///|
test "default semantic actions commit once and are visible to a later predicate" {
  let calls : Array[Int32] = []
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, index) => {
      calls.push(index)
      event.frame.values["ready"] = Json::boolean(true)
      event.frame
    },
    predicate: (event, _) => {
      event.frame.values.get("ready") == Some(Json::boolean(true))
    },
  }
  let result = @attributes.grammar().parse_default("2 3", semantics=bindings)
  assert_true(result.diagnostics.is_empty())
  // One document action and one action in each number invocation.
  assert_eq(calls.length(), 3)
}
