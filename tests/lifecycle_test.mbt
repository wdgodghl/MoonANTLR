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
fn lifecycle_exception(
  rule : Int32,
  failures : Array[String],
  caught~ : Bool = false,
  input~ : String = "x",
) -> (Array[String], String, Int32, String, Array[Int32], Array[Int32], Int32) {
  let events : Array[String] = []
  let totals : Array[Int32] = []
  let final_counts : Array[Int32] = []
  let record : (@runtime.RuleFrame, String) -> Unit raise @runtime.RuntimeError = (
    frame,
    stage,
  ) => {
    let previous = match frame.shared.get("commits") {
      Some(Number(value, ..)) => value.to_int()
      _ => 0
    }
    frame.shared["commits"] = Json::number((previous + 1).to_double())
    events.push(stage)
    if stage == "finally" || stage == "outer-finally" {
      final_counts.push(previous + 1)
    }
    if failures.contains(stage) {
      raise @runtime.Unsupported(stage)
    }
  }
  let grammar = try {
    if caught {
      @exceptions.grammar()
    } else {
      @lifecycle.grammar()
    }
  } catch {
    _ => abort("invalid fixture")
  }
  let sources = if caught {
    @exceptions.parser_action_sources()
  } else {
    @lifecycle.parser_action_sources()
  }
  let mut diagnostics = 0
  let mut tree = ""
  let mut captures = -1
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      let body = sources[ordinal]
      for
        stage in [
          "init", "inline", "after", "finally", "outer-init", "outer-after", "outer-finally",
        ] {
        if body.contains("failIf(\"" + stage + "\")") {
          if event.context.name == "document" &&
            (stage == "inline" || stage == "after" || stage == "finally") {
            let old = match event.frame.values.get("total") {
              Some(Number(value, ..)) => value.to_int()
              _ => 0
            }
            let value = old +
              (if stage == "inline" {
                100
              } else if stage == "after" {
                10
              } else {
                1000
              })
            event.frame.values["total"] = Json::number(value.to_double())
            if stage == "finally" {
              totals.push(value)
            }
          }
          record(event.frame, stage)
          if event.context.name == "document" && stage == "init" {
            event.frame.values["total"] = Json::number(1.0)
          }
        }
      }
      event.frame
    },
  }
  let bindings = {
    ..bindings,
    predicate: (event, _) => event.context.name != "predicate_failure",
    handle_exception: Some((event, error) => {
      let stage = match error {
        @runtime.RecognitionError(kind, _, _, _) =>
          match event.context.name {
            "caught" => "catch"
            "specific" =>
              if kind == "NoViableAltException" {
                "no-viable"
              } else if kind == "InputMismatchException" {
                "mismatch"
              } else {
                raise error
              }
            "predicate_failure" =>
              if kind == "FailedPredicateException" {
                "predicate"
              } else {
                raise error
              }
            _ => raise error
          }
        @runtime.Unsupported(_) =>
          if event.context.name == "caught_host" ||
            event.context.name == "outer" {
            "catch"
          } else {
            raise error
          }
        _ => raise error
      }
      record(event.frame, stage)
      event.frame
    }),
  }
  let failure = try {
    let result = grammar.parse_default(
      input,
      start_rule=rule,
      semantics=bindings,
    )
    diagnostics = result.diagnostics.length()
    tree = result.tree.to_sexpr()
    if result.context.name == "outer" {
      captures = @exceptions.ExceptionsOuterContext::from_raw(result.context)
        .unwrap()
        .label_child()
        .length()
    }
    ""
  } catch {
    @runtime.Unsupported(stage) => stage
    _ => "unexpected error"
  }
  (events, failure, diagnostics, tree, totals, final_counts, captures)
}

///|
test "disabled tree preserves labelled captures and rule spans" {
  let parsed = @typed.grammar().parse_default("x=1;", build_tree=false)
  assert_true(parsed.context.children.is_empty())
  assert_eq(parsed.context.text(), "")
  assert_eq(parsed.context.span(), Some((0, 4)))
  let document = @typed.TypedDocumentContext::from_raw(parsed.context).unwrap()
  assert_eq(document.label_entries()[0].label_key()[0].text, "x")
  assert_eq(
    document.label_entries()[0].label_value()[0].label_number()[0].text,
    "1",
  )
}

///|
test "named lifecycle actions preserve initialization after and finally" {
  let result = @lifecycle.grammar().parse_default(
    "x",
    semantics=lifecycle_bindings(),
  )
  assert_eq(result.frame.unwrap().int_value("total"), Some(1111))
}

///|
test "custom catch metadata is preserved and requires a host binding" {
  assert_eq(@exceptions.rule_exception_sources().length(), 6)
  assert_true(
    @exceptions.rule_exception_sources()[0].1.contains("RecognitionException"),
  )
  let rejected = try {
    ignore(
      @exceptions.grammar().parse_default(
        "x",
        semantics=@runtime.RuleSemantics::new(),
      ),
    )
    false
  } catch {
    @runtime.Unsupported(_) => true
    _ => false
  }
  assert_true(rejected)
}

///|
test "contextual lexer predicates are forwarded by all parsing entries" {
  let grammar = @lexgate.grammar()
  let gate : @runtime.LexerContextPredicate = event => event.text == "if"
  let source = "if ifs"
  let contexts = [
    grammar.parse_detailed(source, lexer_context_predicate=gate).context,
    grammar.parse_prefix(source, lexer_context_predicate=gate).parsed.context,
    grammar.parse_prefix_lazy(source, lexer_context_predicate=gate).parsed.context,
    grammar.parse_context(source, lexer_context_predicate=gate),
    grammar.parse_semantic(
      source,
      @runtime.RuleSemantics::new(),
      lexer_context_predicate=gate,
    ).context,
    grammar.parse_default(source, lexer_context_predicate=gate).context,
  ]
  for context in contexts {
    assert_eq(context.tokens(1).length(), 1)
    assert_eq(context.tokens(1)[0].text, "if")
  }
  assert_eq(
    grammar.parse(source, lexer_context_predicate=gate).to_sexpr(),
    contexts[0].to_tree().to_sexpr(),
  )
  assert_eq(
    @lexgate.LexGateParser::new()
    .parse_document(source, lexer_context_predicate=gate)
    .raw()
    .tokens(1)
    .length(),
    1,
  )
  assert_true(
    grammar.parse_recovering(source, lexer_context_predicate=gate).diagnostics.is_empty(),
  )
}
