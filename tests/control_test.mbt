///|
fn control_boundaries(context : @runtime.RuleContext) -> String {
  let text = context.name +
    ":" +
    context.start_token.map(token => token.start).unwrap_or(-1).to_string() +
    ":" +
    context.stop_token.map(token => token.start).unwrap_or(-1).to_string() +
    ":" +
    context.children.length().to_string()
  text +
  context.children
  .map(child => {
    match child {
      @runtime.RuleChild(context) => "|" + control_boundaries(context)
      _ => ""
    }
  })
  .join("")
}

///|
fn control_bindings() -> @runtime.RuleSemantics {
  {
    ..@runtime.RuleSemantics::new(),
    action: (event, index) => {
      let action = @control.parser_action_sources()[index]
      let control = event.control.unwrap()
      if action.contains("BailErrorStrategy") {
        control.bail = true
      }
      if action.contains("setBuildParseTree(false)") {
        control.build_tree = false
      }
      if action.contains("setBuildParseTree(true)") {
        control.build_tree = true
      }
      event.frame
    },
  }
}

///|
fn control_observation(start : Int32, source : String) -> String {
  let bindings = control_bindings()
  try {
    let parsed = @control.grammar().parse_default(
      source,
      start_rule=start,
      semantics=bindings,
    )
    parsed.tree.to_sexpr() + "\n" + control_boundaries(parsed.context)
  } catch {
    @runtime.ParseCancelled(kind, line, col, _) =>
      "error:" + kind + ":" + line.to_string() + ":" + col.to_string()
    _ => "unexpected runtime failure"
  }
}

///|
test "source spans retain detached children across a live tree toggle" {
  let parsed = @control.grammar().parse_default(
    "a a",
    start_rule=2,
    semantics=control_bindings(),
  )
  assert_eq(parsed.context.children.length(), 2)
  @debug.assert_eq(parsed.context.span(), Some((0, 3)))
  @debug.assert_eq(
    parsed.context.rules("child", states=[24]).map(context => context.span()),
    [Some((0, 1))],
  )
}

///|
test "nested source spans visit shared tree and capture nodes once" {
  let mut input = "1"
  for _ in 0..<40 {
    input = "(" + input + ")"
  }
  let parsed = @typed.grammar().parse_default(input, start_rule=2)
  @debug.assert_eq(parsed.context.span(), Some((0, 81)))
}
