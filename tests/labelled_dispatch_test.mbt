///|
fn typed_java_dispatch(node : @runtime.RuleContext) -> Array[String] {
  let events : Array[String] = []
  let record = (hook : String, context : @runtime.RuleContext) => {
    events.push(hook + ":" + context.name)
  }
  let listener = {
    ..@typed.TypedListener::new(),
    enter: context => record("enterEveryRule", context),
    exit: context => record("exitEveryRule", context),
    terminal: token => events.push("visitTerminal:" + token.text),
    error: token => events.push("visitErrorNode:" + token.text),
    enter_document: context => record("enterDocument", context.raw()),
    exit_document: context => record("exitDocument", context.raw()),
    enter_entry: context => record("enterEntry", context.raw()),
    exit_entry: context => record("exitEntry", context.raw()),
    // Java has alternative-only methods for this labelled rule. Binding these
    // makes any accidental base-rule dispatch visible to the independent oracle.
    enter_expression: context => record("enterExpression", context.raw()),
    exit_expression: context => record("exitExpression", context.raw()),
    enter_alt_Power: context => record("enterPower", context.raw()),
    exit_alt_Power: context => record("exitPower", context.raw()),
    enter_alt_Product: context => record("enterProduct", context.raw()),
    exit_alt_Product: context => record("exitProduct", context.raw()),
    enter_alt_Sum: context => record("enterSum", context.raw()),
    exit_alt_Sum: context => record("exitSum", context.raw()),
    enter_alt_Group: context => record("enterGroup", context.raw()),
    exit_alt_Group: context => record("exitGroup", context.raw()),
    enter_alt_Number: context => record("enterNumber", context.raw()),
    exit_alt_Number: context => record("exitNumber", context.raw()),
  }
  listener.walk(node)
  events
}
