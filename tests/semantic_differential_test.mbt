///|
fn semantic_differential_bindings(
  enabled : Bool,
  trace : StringBuilder,
) -> @runtime.RuleSemantics {
  {
    ..@runtime.RuleSemantics::new(),
    arguments: (event, _) => {
      for (site, expression) in @semantic_differential.argument_expressions() {
        if site == event.site {
          return Map([
            ("n", Json::number(if expression == "1" { 1.0 } else { -1.0 })),
          ])
        }
      }
      Map([])
    },
    predicate: (event, index) => {
      let mut body = ""
      for
        (_, ordinal, source) in @semantic_differential.parser_predicate_sources() {
        if ordinal == index {
          body = source
        }
      }
      let tag = if body.contains("pred(1,") {
        1
      } else if body.contains("pred(2,") {
        2
      } else if body.contains("pred(3,") {
        3
      } else if body.contains("pred(4,") {
        4
      } else if body.contains("pred(5,") {
        5
      } else if body.contains("pred(6,") {
        6
      } else if body.contains("pred(7,") {
        7
      } else {
        8
      }
      trace.write_string(tag.to_string() + ":")
      match tag {
        1 | 3 => enabled
        2 | 5 => !enabled
        4 => true
        6 => event.lookahead(1).text == "foo"
        7 => event.frame.int_value("n").unwrap_or(0) > 0
        8 => event.frame.int_value("n").unwrap_or(0) < 0
        _ => false
      }
    },
  }
}
