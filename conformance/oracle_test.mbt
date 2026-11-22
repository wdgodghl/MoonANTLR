// Generated from pinned ANTLR 4.13.2 upstream runtime descriptors.

///|
test "upstream CompositeLexers LexerDelegatorInvokesDelegateRule" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      (2, 0) => printed.write_string("S.A" + "\n")
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u000.lexer_data()).lexer_cursor(
    "abc",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "S.A\n[@0,0:0='a',<3>,1:0]\n[@1,1:1='b',<1>,1:1]\n[@2,2:2='c',<4>,1:2]\n[@3,3:2='<EOF>',<-1>,1:3]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "a", 0, 1, 1, 0, 0),
      (1, "b", 1, 2, 1, 1, 0),
      (4, "c", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream CompositeLexers LexerDelegatorRuleOverridesDelegate" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      (0, 0) => printed.write_string("M.A" + "\n")
      (2, 1) => printed.write_string("S.B" + "\n")
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u001.lexer_data()).lexer_cursor(
    "ab",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "M.A\n[@0,0:1='ab',<1>,1:0]\n[@1,2:1='<EOF>',<-1>,1:2]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "ab", 0, 2, 1, 0, 0), (-1, "<EOF>", 2, 2, 1, 2, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream CompositeParsers BringInLiteralsFromDelegate" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("S.a")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u002.grammar()
  let parsed = grammar.parse_default(
    "=a",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 2)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"=\" \"a\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("=a", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "=a")
  assert_eq(printed.to_string(), "S.a")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:=", "token:a", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "=", 0, 1, 1, 0, 0),
      (2, "a", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream CompositeParsers CombinedImportsCombined" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("S.x" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u003.grammar()
  let parsed = grammar.parse_default(
    "x 34 9",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(parsed.tree.to_sexpr(), "(s (x \"x\" \"34\") \"9\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x 34 9", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "x349")
  assert_eq(printed.to_string(), "S.x\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:x", "token:x", "token:34", "exit:x", "token:9", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "x", 0, 1, 1, 0, 0),
      (2, "34", 2, 4, 1, 2, 0),
      (2, "9", 5, 6, 1, 5, 0),
      (-1, "<EOF>", 6, 6, 1, 6, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream CompositeParsers DelegatesSeeSameTokenType" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("S.x" + "\n")
        1 => printed.write_string("T.y" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u004.grammar()
  let parsed = grammar.parse_default(
    "aa",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1), (1, 2)])
  assert_eq(parsed.tree.to_sexpr(), "(s (x \"a\") (y \"a\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("aa", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "aa")
  assert_eq(printed.to_string(), "S.x\nT.y\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:x", "token:a", "exit:x", "enter:y", "token:a", "exit:y", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "a", 0, 1, 1, 0, 0),
      (2, "a", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream CompositeParsers DelegatorAccessesDelegateMembers" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("foo\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u005.grammar()
  let parsed = grammar.parse_default(
    "b",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s \"b\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("b", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "b")
  assert_eq(printed.to_string(), "foo\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "token:b", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "b", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream CompositeParsers DelegatorInvokesDelegateRule" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("S.a" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u006.grammar()
  let parsed = grammar.parse_default(
    "b",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"b\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("b", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "b")
  assert_eq(printed.to_string(), "S.a\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:b", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "b", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream CompositeParsers DelegatorInvokesDelegateRuleWithArgs" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    enter: (rule, frame) => {
      if rule == 1 && !frame.values.contains("x") {
        frame.values["x"] = Json::number(0.0)
      }
      if rule == 1 && !frame.values.contains("y") {
        frame.values["y"] = Json::number(0.0)
      }
      frame
    },
    wrap: (rule, previous) => {
      let values : Map[String, Json] = Map([])
      if rule == 1 {
        if previous.values.get("x") is Some(value) {
          values["x"] = value
        }
      }
      if rule == 1 && !values.contains("x") {
        values["x"] = Json::number(0.0)
      }
      if rule == 1 && !values.contains("y") {
        values["y"] = Json::number(0.0)
      }
      { values, shared: previous.shared.copy(), children: [previous], }
    },
    arguments: (event, _) => {
      match event.site {
        4 => Map([("x", Json::number((3).to_double()))])
        _ => Map([])
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("S.a")
        1 =>
          printed.write_string(
            bound_int(bound_label(event, [4]).values, "y").to_string() + "\n",
          )
        2 => event.frame.values["y"] = Json::number((1000).to_double())
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u007.grammar()
  let parsed = grammar.parse_default(
    "b",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1), (2, 1), (1, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"b\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("b", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{\"x\":3,\"y\":1000},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "b")
  assert_eq(printed.to_string(), "S.a1000\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:b", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "b", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream CompositeParsers DelegatorInvokesDelegateRuleWithReturnStruct" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("S.a")
        1 =>
          printed.write_string(
            observed_text(event, observed_context(event, "a", []), false),
          )
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u008.grammar()
  let parsed = grammar.parse_default(
    "b",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1), (1, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"b\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("b", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "b")
  assert_eq(printed.to_string(), "S.ab")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:b", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "b", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream CompositeParsers DelegatorInvokesFirstVersionOfDelegateRule" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("S.a" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u009.grammar()
  let parsed = grammar.parse_default(
    "b",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a (b \"b\")))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("b", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "b")
  assert_eq(printed.to_string(), "S.a\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "enter:b", "token:b", "exit:b", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "b", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream CompositeParsers DelegatorRuleOverridesDelegate" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("S.a")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u010.grammar()
  let parsed = grammar.parse_default(
    "c",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=1,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(a (b \"c\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("c", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "c")
  assert_eq(printed.to_string(), "S.a")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "enter:b", "token:c", "exit:b", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(2, "c", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream CompositeParsers DelegatorRuleOverridesDelegates" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("S.a" + "\n")
        1 => printed.write_string("M.b" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u011.grammar()
  let parsed = grammar.parse_default(
    "c",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=1,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(1, 1), (0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(a (b \"c\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("c", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "c")
  assert_eq(printed.to_string(), "M.b\nS.a\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "enter:b", "token:c", "exit:b", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(2, "c", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream CompositeParsers DelegatorRuleOverridesLookaheadInDelegate" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(
            "JavaDecl: " + observed_text(event, event.context, true) + "\n",
          )
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u012.grammar()
  let parsed = grammar.parse_default(
    "float x = 3;",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 12)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(prog (decl (type_ \"float\") \"x\" (init_ \"=\" \"3\") \";\"))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("float x = 3;", lexer_action=(_, _) => {
    ()
  })
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "floatx=3;")
  assert_eq(printed.to_string(), "JavaDecl: floatx=3;\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:prog", "enter:decl", "enter:type_", "token:float", "exit:type_", "token:x",
    "enter:init_", "token:=", "token:3", "exit:init_", "token:;", "exit:decl", "exit:prog",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "float", 0, 5, 1, 0, 0),
      (5, "x", 6, 7, 1, 6, 0),
      (4, "=", 8, 9, 1, 8, 0),
      (6, "3", 10, 11, 1, 10, 0),
      (3, ";", 11, 12, 1, 11, 0),
      (-1, "<EOF>", 12, 12, 1, 12, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream CompositeParsers ImportedGrammarWithEmptyOptions" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u013.grammar()
  let parsed = grammar.parse_default(
    "b",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"b\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("b", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "b")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:b", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "b", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream CompositeParsers ImportedRuleWithAction" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u014.grammar()
  let parsed = grammar.parse_default(
    "b",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"b\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("b", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "b")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:b", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "b", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream CompositeParsers ImportLexerWithOnlyFragmentRules" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u015.grammar()
  let parsed = grammar.parse_default(
    "test test",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(program \"test\" \"test\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("test test", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "testtest")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:program", "token:test", "token:test", "exit:program",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "test", 0, 4, 1, 0, 0),
      (1, "test", 5, 9, 1, 5, 0),
      (-1, "<EOF>", 9, 9, 1, 9, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream CompositeParsers KeywordVSIDOrder" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(
            "M.a: " +
            observed_token_string(observed_token(event, 1, []), event.tokens) +
            "\n",
          )
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      (0, 0) => printed.write_string("M.A" + "\n")
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u016.grammar()
  let parsed = grammar.parse_default(
    "abc",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"abc\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("abc", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "abc")
  assert_eq(printed.to_string(), "M.A\nM.a: [@0,0:2='abc',<1>,1:0]\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:abc", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "abc", 0, 3, 1, 0, 0), (-1, "<EOF>", 3, 3, 1, 3, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream FullContextParsing AmbiguityNoLoop" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("alt 1" + "\n")
        1 =>
          event.control.unwrap().prediction_mode = @runtime.LL_EXACT_AMBIG_DETECTION
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u017.grammar()
  let parsed = grammar.parse_default(
    "a@",
    report_prediction=true,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(1, 0), (0, 2)])
  assert_eq(parsed.tree.to_sexpr(), "(prog (expr \"a\") (expr \"@\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(2)),
    (Some(1), Some(2)),
    (Some(1), Some(2)),
    (Some(1), Some(2)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a@", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a@")
  assert_eq(printed.to_string(), "alt 1\n")
  let expected_prediction : Json = [
    {
      "kind": "attempting_full_context",
      "decision": 0,
      "start": 0,
      "stop": 2,
      "exact": false,
      "alternatives": [1, 2],
      "prediction": 0,
    },
    {
      "kind": "ambiguity",
      "decision": 0,
      "start": 0,
      "stop": 2,
      "exact": true,
      "alternatives": [1, 2],
      "prediction": 0,
    },
    {
      "kind": "attempting_full_context",
      "decision": 1,
      "start": 0,
      "stop": 2,
      "exact": false,
      "alternatives": [2, 3],
      "prediction": 0,
    },
    {
      "kind": "context_sensitivity",
      "decision": 1,
      "start": 0,
      "stop": 2,
      "exact": false,
      "alternatives": [],
      "prediction": 3,
    },
  ]
  @debug.assert_eq(
    Json::array(parsed.prediction_events.map(event => event.to_json())),
    expected_prediction,
  )
  assert_eq(
    parsed.diagnostics
    .filter(d => d.code.has_prefix("prediction_"))
    .map(d => {
      "line " +
      d.line.unwrap().to_string() +
      ":" +
      d.column.unwrap().to_string() +
      " " +
      d.message +
      "\n"
    })
    .join(""),
    "line 1:2 reportAttemptingFullContext d=0 (prog), input='a@'\nline 1:2 reportAmbiguity d=0 (prog): ambigAlts={1, 2}, input='a@'\nline 1:2 reportAttemptingFullContext d=1 (expr), input='a@'\nline 1:2 reportContextSensitivity d=1 (expr), input='a@'\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:prog", "enter:expr", "token:a", "exit:expr", "enter:expr", "token:@",
    "exit:expr", "exit:prog",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "a", 0, 1, 1, 0, 0),
      (1, "@", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream FullContextParsing AmbigYieldsCtxSensitiveDFA" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        1 => printed.write_string(event.control.unwrap().dump_dfa())
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u018.grammar()
  let parsed = grammar.parse_default(
    "abc",
    report_prediction=true,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(1, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(s \"abc\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(0)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("abc", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "abc")
  assert_eq(printed.to_string(), "Decision 0:\ns0-ID->:s1^=>1\n")
  let expected_prediction : Json = [
    {
      "kind": "attempting_full_context",
      "decision": 0,
      "start": 0,
      "stop": 0,
      "exact": false,
      "alternatives": [1, 2],
      "prediction": 0,
    },
    {
      "kind": "ambiguity",
      "decision": 0,
      "start": 0,
      "stop": 0,
      "exact": false,
      "alternatives": [1, 2],
      "prediction": 0,
    },
  ]
  @debug.assert_eq(
    Json::array(parsed.prediction_events.map(event => event.to_json())),
    expected_prediction,
  )
  assert_eq(
    parsed.diagnostics
    .filter(d => d.code.has_prefix("prediction_"))
    .map(d => {
      "line " +
      d.line.unwrap().to_string() +
      ":" +
      d.column.unwrap().to_string() +
      " " +
      d.message +
      "\n"
    })
    .join(""),
    "line 1:0 reportAttemptingFullContext d=0 (s), input='abc'\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "token:abc", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "abc", 0, 3, 1, 0, 0), (-1, "<EOF>", 3, 3, 1, 3, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream FullContextParsing CtxSensitiveDFA_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(event.control.unwrap().dump_dfa())
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u019.grammar()
  let parsed = grammar.parse_default(
    "$ 34 abc",
    report_prediction=true,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 8)])
  assert_eq(parsed.tree.to_sexpr(), "(s \"$\" (a (e \"34\") \"abc\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(5)),
    (Some(1), Some(2)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("$ 34 abc", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "$34abc")
  assert_eq(printed.to_string(), "Decision 1:\ns0-INT->s1\ns1-ID->:s2^=>1\n")
  let expected_prediction : Json = [
    {
      "kind": "attempting_full_context",
      "decision": 1,
      "start": 2,
      "stop": 5,
      "exact": false,
      "alternatives": [1, 2],
      "prediction": 0,
    },
    {
      "kind": "context_sensitivity",
      "decision": 1,
      "start": 2,
      "stop": 2,
      "exact": false,
      "alternatives": [],
      "prediction": 1,
    },
  ]
  @debug.assert_eq(
    Json::array(parsed.prediction_events.map(event => event.to_json())),
    expected_prediction,
  )
  assert_eq(
    parsed.diagnostics
    .filter(d => d.code.has_prefix("prediction_"))
    .map(d => {
      "line " +
      d.line.unwrap().to_string() +
      ":" +
      d.column.unwrap().to_string() +
      " " +
      d.message +
      "\n"
    })
    .join(""),
    "line 1:5 reportAttemptingFullContext d=1 (e), input='34abc'\nline 1:2 reportContextSensitivity d=1 (e), input='34'\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "token:$", "enter:a", "enter:e", "token:34", "exit:e", "token:abc",
    "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "$", 0, 1, 1, 0, 0),
      (4, "34", 2, 4, 1, 2, 0),
      (3, "abc", 5, 8, 1, 5, 0),
      (-1, "<EOF>", 8, 8, 1, 8, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream FullContextParsing CtxSensitiveDFA_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(event.control.unwrap().dump_dfa())
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u020.grammar()
  let parsed = grammar.parse_default(
    "@ 34 abc",
    report_prediction=true,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 8)])
  assert_eq(parsed.tree.to_sexpr(), "(s \"@\" (b (e) \"34\" \"abc\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(5)),
    (Some(1), Some(5)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("@ 34 abc", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "@34abc")
  assert_eq(printed.to_string(), "Decision 1:\ns0-INT->s1\ns1-ID->:s2^=>1\n")
  let expected_prediction : Json = [
    {
      "kind": "attempting_full_context",
      "decision": 1,
      "start": 2,
      "stop": 5,
      "exact": false,
      "alternatives": [1, 2],
      "prediction": 0,
    },
    {
      "kind": "context_sensitivity",
      "decision": 1,
      "start": 2,
      "stop": 5,
      "exact": false,
      "alternatives": [],
      "prediction": 2,
    },
  ]
  @debug.assert_eq(
    Json::array(parsed.prediction_events.map(event => event.to_json())),
    expected_prediction,
  )
  assert_eq(
    parsed.diagnostics
    .filter(d => d.code.has_prefix("prediction_"))
    .map(d => {
      "line " +
      d.line.unwrap().to_string() +
      ":" +
      d.column.unwrap().to_string() +
      " " +
      d.message +
      "\n"
    })
    .join(""),
    "line 1:5 reportAttemptingFullContext d=1 (e), input='34abc'\nline 1:5 reportContextSensitivity d=1 (e), input='34abc'\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "token:@", "enter:b", "enter:e", "exit:e", "token:34", "token:abc",
    "exit:b", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "@", 0, 1, 1, 0, 0),
      (4, "34", 2, 4, 1, 2, 0),
      (3, "abc", 5, 8, 1, 5, 0),
      (-1, "<EOF>", 8, 8, 1, 8, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream FullContextParsing CtxSensitiveDFATwoDiffInput" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(event.control.unwrap().dump_dfa())
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u021.grammar()
  let parsed = grammar.parse_default(
    "$ 34 abc @ 34 abc",
    report_prediction=true,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 17)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s \"$\" (a (e \"34\") \"abc\") \"@\" (b (e) \"34\" \"abc\"))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(5)),
    (Some(1), Some(2)),
    (Some(1), Some(14)),
    (Some(1), Some(14)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("$ 34 abc @ 34 abc", lexer_action=(
    _,
    _,
  ) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "$34abc@34abc")
  assert_eq(printed.to_string(), "Decision 2:\ns0-INT->s1\ns1-ID->:s2^=>1\n")
  let expected_prediction : Json = [
    {
      "kind": "attempting_full_context",
      "decision": 2,
      "start": 2,
      "stop": 5,
      "exact": false,
      "alternatives": [1, 2],
      "prediction": 0,
    },
    {
      "kind": "context_sensitivity",
      "decision": 2,
      "start": 2,
      "stop": 2,
      "exact": false,
      "alternatives": [],
      "prediction": 1,
    },
    {
      "kind": "attempting_full_context",
      "decision": 2,
      "start": 11,
      "stop": 14,
      "exact": false,
      "alternatives": [1, 2],
      "prediction": 0,
    },
    {
      "kind": "context_sensitivity",
      "decision": 2,
      "start": 11,
      "stop": 14,
      "exact": false,
      "alternatives": [],
      "prediction": 2,
    },
  ]
  @debug.assert_eq(
    Json::array(parsed.prediction_events.map(event => event.to_json())),
    expected_prediction,
  )
  assert_eq(
    parsed.diagnostics
    .filter(d => d.code.has_prefix("prediction_"))
    .map(d => {
      "line " +
      d.line.unwrap().to_string() +
      ":" +
      d.column.unwrap().to_string() +
      " " +
      d.message +
      "\n"
    })
    .join(""),
    "line 1:5 reportAttemptingFullContext d=2 (e), input='34abc'\nline 1:2 reportContextSensitivity d=2 (e), input='34'\nline 1:14 reportAttemptingFullContext d=2 (e), input='34abc'\nline 1:14 reportContextSensitivity d=2 (e), input='34abc'\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "token:$", "enter:a", "enter:e", "token:34", "exit:e", "token:abc",
    "exit:a", "token:@", "enter:b", "enter:e", "exit:e", "token:34", "token:abc",
    "exit:b", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "$", 0, 1, 1, 0, 0),
      (4, "34", 2, 4, 1, 2, 0),
      (3, "abc", 5, 8, 1, 5, 0),
      (2, "@", 9, 10, 1, 9, 0),
      (4, "34", 11, 13, 1, 11, 0),
      (3, "abc", 14, 17, 1, 14, 0),
      (-1, "<EOF>", 17, 17, 1, 17, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream FullContextParsing ExprAmbiguity_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    enter: (rule, frame) => {
      if rule == 1 && !frame.values.contains("_p") {
        frame.values["_p"] = Json::number(0.0)
      }
      frame
    },
    wrap: (rule, previous) => {
      let values : Map[String, Json] = Map([])
      if rule == 1 {
        if previous.values.get("_p") is Some(value) {
          values["_p"] = value
        }
      }
      if rule == 1 && !values.contains("_p") {
        values["_p"] = Json::number(0.0)
      }
      { values, shared: previous.shared.copy(), children: [previous], }
    },
    arguments: (event, _) => {
      match event.site {
        4 => Map([("_p", Json::number((0).to_double()))])
        10 => Map([("_p", Json::number((6).to_double()))])
        13 => Map([("_p", Json::number((5).to_double()))])
        _ => Map([])
      }
    },
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => 5 >= bound_int(event.frame.values, "_p")
        1 => 4 >= bound_int(event.frame.values, "_p")
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(
            observed_tree(observed_context(event, "expr", [])) + "\n",
          )
        1 =>
          event.control.unwrap().prediction_mode = @runtime.LL_EXACT_AMBIG_DETECTION
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u022.grammar()
  let parsed = grammar.parse_default(
    "a+b",
    report_prediction=true,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(1, 0), (0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(s (expr \"a\" \"+\" (expr \"b\")))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(1)),
    (Some(1), Some(2)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a+b", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{\"_p\":0},\"children\":[{\"values\":{\"_p\":5},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a+b")
  assert_eq(printed.to_string(), "(expr a + (expr b))\n")
  let expected_prediction : Json = [
    {
      "kind": "attempting_full_context",
      "decision": 1,
      "start": 1,
      "stop": 1,
      "exact": false,
      "alternatives": [1, 2],
      "prediction": 0,
    },
    {
      "kind": "context_sensitivity",
      "decision": 1,
      "start": 1,
      "stop": 2,
      "exact": false,
      "alternatives": [],
      "prediction": 1,
    },
  ]
  @debug.assert_eq(
    Json::array(parsed.prediction_events.map(event => event.to_json())),
    expected_prediction,
  )
  assert_eq(
    parsed.diagnostics
    .filter(d => d.code.has_prefix("prediction_"))
    .map(d => {
      "line " +
      d.line.unwrap().to_string() +
      ":" +
      d.column.unwrap().to_string() +
      " " +
      d.message +
      "\n"
    })
    .join(""),
    "line 1:1 reportAttemptingFullContext d=1 (expr), input='+'\nline 1:2 reportContextSensitivity d=1 (expr), input='+b'\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:expr", "token:a", "token:+", "enter:expr", "token:b", "exit:expr",
    "exit:expr", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "a", 0, 1, 1, 0, 0),
      (2, "+", 1, 2, 1, 1, 0),
      (3, "b", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream FullContextParsing ExprAmbiguity_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    enter: (rule, frame) => {
      if rule == 1 && !frame.values.contains("_p") {
        frame.values["_p"] = Json::number(0.0)
      }
      frame
    },
    wrap: (rule, previous) => {
      let values : Map[String, Json] = Map([])
      if rule == 1 {
        if previous.values.get("_p") is Some(value) {
          values["_p"] = value
        }
      }
      if rule == 1 && !values.contains("_p") {
        values["_p"] = Json::number(0.0)
      }
      { values, shared: previous.shared.copy(), children: [previous], }
    },
    arguments: (event, _) => {
      match event.site {
        4 => Map([("_p", Json::number((0).to_double()))])
        10 => Map([("_p", Json::number((6).to_double()))])
        13 => Map([("_p", Json::number((5).to_double()))])
        _ => Map([])
      }
    },
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => 5 >= bound_int(event.frame.values, "_p")
        1 => 4 >= bound_int(event.frame.values, "_p")
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(
            observed_tree(observed_context(event, "expr", [])) + "\n",
          )
        1 =>
          event.control.unwrap().prediction_mode = @runtime.LL_EXACT_AMBIG_DETECTION
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u023.grammar()
  let parsed = grammar.parse_default(
    "a+b*c",
    report_prediction=true,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(1, 0), (0, 5)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (expr \"a\" \"+\" (expr \"b\" \"*\" (expr \"c\"))))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(1)),
    (Some(1), Some(2)),
    (Some(1), Some(3)),
    (Some(1), Some(5)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a+b*c", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{\"_p\":0},\"children\":[{\"values\":{\"_p\":5},\"children\":[{\"values\":{\"_p\":6},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a+b*c")
  assert_eq(printed.to_string(), "(expr a + (expr b * (expr c)))\n")
  let expected_prediction : Json = [
    {
      "kind": "attempting_full_context",
      "decision": 1,
      "start": 1,
      "stop": 1,
      "exact": false,
      "alternatives": [1, 2],
      "prediction": 0,
    },
    {
      "kind": "context_sensitivity",
      "decision": 1,
      "start": 1,
      "stop": 2,
      "exact": false,
      "alternatives": [],
      "prediction": 1,
    },
    {
      "kind": "attempting_full_context",
      "decision": 1,
      "start": 3,
      "stop": 3,
      "exact": false,
      "alternatives": [1, 2],
      "prediction": 0,
    },
    {
      "kind": "ambiguity",
      "decision": 1,
      "start": 3,
      "stop": 5,
      "exact": true,
      "alternatives": [1, 2],
      "prediction": 0,
    },
  ]
  @debug.assert_eq(
    Json::array(parsed.prediction_events.map(event => event.to_json())),
    expected_prediction,
  )
  assert_eq(
    parsed.diagnostics
    .filter(d => d.code.has_prefix("prediction_"))
    .map(d => {
      "line " +
      d.line.unwrap().to_string() +
      ":" +
      d.column.unwrap().to_string() +
      " " +
      d.message +
      "\n"
    })
    .join(""),
    "line 1:1 reportAttemptingFullContext d=1 (expr), input='+'\nline 1:2 reportContextSensitivity d=1 (expr), input='+b'\nline 1:3 reportAttemptingFullContext d=1 (expr), input='*'\nline 1:5 reportAmbiguity d=1 (expr): ambigAlts={1, 2}, input='*c'\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:expr", "token:a", "token:+", "enter:expr", "token:b", "token:*",
    "enter:expr", "token:c", "exit:expr", "exit:expr", "exit:expr", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "a", 0, 1, 1, 0, 0),
      (2, "+", 1, 2, 1, 1, 0),
      (3, "b", 2, 3, 1, 2, 0),
      (1, "*", 3, 4, 1, 3, 0),
      (3, "c", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream FullContextParsing FullContextIF_THEN_ELSEParse_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          event.control.unwrap().prediction_mode = @runtime.LL_EXACT_AMBIG_DETECTION
        1 => printed.write_string(event.control.unwrap().dump_dfa())
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u024.grammar()
  let parsed = grammar.parse_default(
    "{ if x then return }",
    report_prediction=true,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 0), (1, 20)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s \"{\" (stat \"if\" \"x\" \"then\" (stat \"return\")) \"}\")",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("{ if x then return }", lexer_action=(
    _,
    _,
  ) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "{ifxthenreturn}")
  assert_eq(printed.to_string(), "Decision 1:\ns0-'}'->:s1=>2\n")
  let expected_prediction : Json = []
  @debug.assert_eq(
    Json::array(parsed.prediction_events.map(event => event.to_json())),
    expected_prediction,
  )
  assert_eq(
    parsed.diagnostics
    .filter(d => d.code.has_prefix("prediction_"))
    .map(d => {
      "line " +
      d.line.unwrap().to_string() +
      ":" +
      d.column.unwrap().to_string() +
      " " +
      d.message +
      "\n"
    })
    .join(""),
    "",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "token:{", "enter:stat", "token:if", "token:x", "token:then", "enter:stat",
    "token:return", "exit:stat", "exit:stat", "token:}", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "{", 0, 1, 1, 0, 0),
      (3, "if", 2, 4, 1, 2, 0),
      (7, "x", 5, 6, 1, 5, 0),
      (4, "then", 7, 11, 1, 7, 0),
      (6, "return", 12, 18, 1, 12, 0),
      (2, "}", 19, 20, 1, 19, 0),
      (-1, "<EOF>", 20, 20, 1, 20, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream FullContextParsing FullContextIF_THEN_ELSEParse_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          event.control.unwrap().prediction_mode = @runtime.LL_EXACT_AMBIG_DETECTION
        1 => printed.write_string(event.control.unwrap().dump_dfa())
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u025.grammar()
  let parsed = grammar.parse_default(
    "{ if x then return else foo }",
    report_prediction=true,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 0), (1, 29)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s \"{\" (stat \"if\" \"x\" \"then\" (stat \"return\") \"else\" \"foo\") \"}\")",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(19)),
    (Some(1), Some(19)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("{ if x then return else foo }", lexer_action=(
    _,
    _,
  ) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "{ifxthenreturnelsefoo}")
  assert_eq(printed.to_string(), "Decision 1:\ns0-'else'->:s1^=>1\n")
  let expected_prediction : Json = [
    {
      "kind": "attempting_full_context",
      "decision": 1,
      "start": 19,
      "stop": 19,
      "exact": false,
      "alternatives": [1, 2],
      "prediction": 0,
    },
    {
      "kind": "context_sensitivity",
      "decision": 1,
      "start": 19,
      "stop": 19,
      "exact": false,
      "alternatives": [],
      "prediction": 1,
    },
  ]
  @debug.assert_eq(
    Json::array(parsed.prediction_events.map(event => event.to_json())),
    expected_prediction,
  )
  assert_eq(
    parsed.diagnostics
    .filter(d => d.code.has_prefix("prediction_"))
    .map(d => {
      "line " +
      d.line.unwrap().to_string() +
      ":" +
      d.column.unwrap().to_string() +
      " " +
      d.message +
      "\n"
    })
    .join(""),
    "line 1:19 reportAttemptingFullContext d=1 (stat), input='else'\nline 1:19 reportContextSensitivity d=1 (stat), input='else'\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "token:{", "enter:stat", "token:if", "token:x", "token:then", "enter:stat",
    "token:return", "exit:stat", "token:else", "token:foo", "exit:stat", "token:}",
    "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "{", 0, 1, 1, 0, 0),
      (3, "if", 2, 4, 1, 2, 0),
      (7, "x", 5, 6, 1, 5, 0),
      (4, "then", 7, 11, 1, 7, 0),
      (6, "return", 12, 18, 1, 12, 0),
      (5, "else", 19, 23, 1, 19, 0),
      (7, "foo", 24, 27, 1, 24, 0),
      (2, "}", 28, 29, 1, 28, 0),
      (-1, "<EOF>", 29, 29, 1, 29, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream FullContextParsing FullContextIF_THEN_ELSEParse_3" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          event.control.unwrap().prediction_mode = @runtime.LL_EXACT_AMBIG_DETECTION
        1 => printed.write_string(event.control.unwrap().dump_dfa())
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u026.grammar()
  let parsed = grammar.parse_default(
    "{ if x then if y then return else foo }",
    report_prediction=true,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 0), (1, 39)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s \"{\" (stat \"if\" \"x\" \"then\" (stat \"if\" \"y\" \"then\" (stat \"return\") \"else\" \"foo\")) \"}\")",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(29)),
    (Some(1), Some(38)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering(
    "{ if x then if y then return else foo }",
    lexer_action=(_, _) => (),
  )
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "{ifxthenifythenreturnelsefoo}")
  assert_eq(
    printed.to_string(),
    "Decision 1:\ns0-'}'->:s2=>2\ns0-'else'->:s1^=>1\n",
  )
  let expected_prediction : Json = [
    {
      "kind": "attempting_full_context",
      "decision": 1,
      "start": 29,
      "stop": 29,
      "exact": false,
      "alternatives": [1, 2],
      "prediction": 0,
    },
    {
      "kind": "ambiguity",
      "decision": 1,
      "start": 29,
      "stop": 38,
      "exact": true,
      "alternatives": [1, 2],
      "prediction": 0,
    },
  ]
  @debug.assert_eq(
    Json::array(parsed.prediction_events.map(event => event.to_json())),
    expected_prediction,
  )
  assert_eq(
    parsed.diagnostics
    .filter(d => d.code.has_prefix("prediction_"))
    .map(d => {
      "line " +
      d.line.unwrap().to_string() +
      ":" +
      d.column.unwrap().to_string() +
      " " +
      d.message +
      "\n"
    })
    .join(""),
    "line 1:29 reportAttemptingFullContext d=1 (stat), input='else'\nline 1:38 reportAmbiguity d=1 (stat): ambigAlts={1, 2}, input='elsefoo}'\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "token:{", "enter:stat", "token:if", "token:x", "token:then", "enter:stat",
    "token:if", "token:y", "token:then", "enter:stat", "token:return", "exit:stat",
    "token:else", "token:foo", "exit:stat", "exit:stat", "token:}", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "{", 0, 1, 1, 0, 0),
      (3, "if", 2, 4, 1, 2, 0),
      (7, "x", 5, 6, 1, 5, 0),
      (4, "then", 7, 11, 1, 7, 0),
      (3, "if", 12, 14, 1, 12, 0),
      (7, "y", 15, 16, 1, 15, 0),
      (4, "then", 17, 21, 1, 17, 0),
      (6, "return", 22, 28, 1, 22, 0),
      (5, "else", 29, 33, 1, 29, 0),
      (7, "foo", 34, 37, 1, 34, 0),
      (2, "}", 38, 39, 1, 38, 0),
      (-1, "<EOF>", 39, 39, 1, 39, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream FullContextParsing FullContextIF_THEN_ELSEParse_4" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          event.control.unwrap().prediction_mode = @runtime.LL_EXACT_AMBIG_DETECTION
        1 => printed.write_string(event.control.unwrap().dump_dfa())
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u027.grammar()
  let parsed = grammar.parse_default(
    "{ if x then if y then return else foo else bar }",
    report_prediction=true,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 0), (1, 48)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s \"{\" (stat \"if\" \"x\" \"then\" (stat \"if\" \"y\" \"then\" (stat \"return\") \"else\" \"foo\") \"else\" \"bar\") \"}\")",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(29)),
    (Some(1), Some(38)),
    (Some(1), Some(38)),
    (Some(1), Some(38)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering(
    "{ if x then if y then return else foo else bar }",
    lexer_action=(_, _) => (),
  )
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "{ifxthenifythenreturnelsefooelsebar}")
  assert_eq(printed.to_string(), "Decision 1:\ns0-'else'->:s1^=>1\n")
  let expected_prediction : Json = [
    {
      "kind": "attempting_full_context",
      "decision": 1,
      "start": 29,
      "stop": 29,
      "exact": false,
      "alternatives": [1, 2],
      "prediction": 0,
    },
    {
      "kind": "context_sensitivity",
      "decision": 1,
      "start": 29,
      "stop": 38,
      "exact": false,
      "alternatives": [],
      "prediction": 1,
    },
    {
      "kind": "attempting_full_context",
      "decision": 1,
      "start": 38,
      "stop": 38,
      "exact": false,
      "alternatives": [1, 2],
      "prediction": 0,
    },
    {
      "kind": "context_sensitivity",
      "decision": 1,
      "start": 38,
      "stop": 38,
      "exact": false,
      "alternatives": [],
      "prediction": 1,
    },
  ]
  @debug.assert_eq(
    Json::array(parsed.prediction_events.map(event => event.to_json())),
    expected_prediction,
  )
  assert_eq(
    parsed.diagnostics
    .filter(d => d.code.has_prefix("prediction_"))
    .map(d => {
      "line " +
      d.line.unwrap().to_string() +
      ":" +
      d.column.unwrap().to_string() +
      " " +
      d.message +
      "\n"
    })
    .join(""),
    "line 1:29 reportAttemptingFullContext d=1 (stat), input='else'\nline 1:38 reportContextSensitivity d=1 (stat), input='elsefooelse'\nline 1:38 reportAttemptingFullContext d=1 (stat), input='else'\nline 1:38 reportContextSensitivity d=1 (stat), input='else'\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "token:{", "enter:stat", "token:if", "token:x", "token:then", "enter:stat",
    "token:if", "token:y", "token:then", "enter:stat", "token:return", "exit:stat",
    "token:else", "token:foo", "exit:stat", "token:else", "token:bar", "exit:stat",
    "token:}", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "{", 0, 1, 1, 0, 0),
      (3, "if", 2, 4, 1, 2, 0),
      (7, "x", 5, 6, 1, 5, 0),
      (4, "then", 7, 11, 1, 7, 0),
      (3, "if", 12, 14, 1, 12, 0),
      (7, "y", 15, 16, 1, 15, 0),
      (4, "then", 17, 21, 1, 17, 0),
      (6, "return", 22, 28, 1, 22, 0),
      (5, "else", 29, 33, 1, 29, 0),
      (7, "foo", 34, 37, 1, 34, 0),
      (5, "else", 38, 42, 1, 38, 0),
      (7, "bar", 43, 46, 1, 43, 0),
      (2, "}", 47, 48, 1, 47, 0),
      (-1, "<EOF>", 48, 48, 1, 48, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream FullContextParsing FullContextIF_THEN_ELSEParse_5" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          event.control.unwrap().prediction_mode = @runtime.LL_EXACT_AMBIG_DETECTION
        1 => printed.write_string(event.control.unwrap().dump_dfa())
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u028.grammar()
  let parsed = grammar.parse_default(
    "{ if x then return else foo\nif x then if y then return else foo }\n",
    report_prediction=true,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 0), (1, 66)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s \"{\" (stat \"if\" \"x\" \"then\" (stat \"return\") \"else\" \"foo\") (stat \"if\" \"x\" \"then\" (stat \"if\" \"y\" \"then\" (stat \"return\") \"else\" \"foo\")) \"}\")",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(19)),
    (Some(1), Some(19)),
    (Some(2), Some(27)),
    (Some(2), Some(36)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering(
    "{ if x then return else foo\nif x then if y then return else foo }\n",
    lexer_action=(_, _) => (),
  )
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(
    parsed.context.get_text(),
    "{ifxthenreturnelsefooifxthenifythenreturnelsefoo}",
  )
  assert_eq(
    printed.to_string(),
    "Decision 1:\ns0-'}'->:s2=>2\ns0-'else'->:s1^=>1\n",
  )
  let expected_prediction : Json = [
    {
      "kind": "attempting_full_context",
      "decision": 1,
      "start": 19,
      "stop": 19,
      "exact": false,
      "alternatives": [1, 2],
      "prediction": 0,
    },
    {
      "kind": "context_sensitivity",
      "decision": 1,
      "start": 19,
      "stop": 19,
      "exact": false,
      "alternatives": [],
      "prediction": 1,
    },
    {
      "kind": "attempting_full_context",
      "decision": 1,
      "start": 55,
      "stop": 55,
      "exact": false,
      "alternatives": [1, 2],
      "prediction": 0,
    },
    {
      "kind": "ambiguity",
      "decision": 1,
      "start": 55,
      "stop": 64,
      "exact": true,
      "alternatives": [1, 2],
      "prediction": 0,
    },
  ]
  @debug.assert_eq(
    Json::array(parsed.prediction_events.map(event => event.to_json())),
    expected_prediction,
  )
  assert_eq(
    parsed.diagnostics
    .filter(d => d.code.has_prefix("prediction_"))
    .map(d => {
      "line " +
      d.line.unwrap().to_string() +
      ":" +
      d.column.unwrap().to_string() +
      " " +
      d.message +
      "\n"
    })
    .join(""),
    "line 1:19 reportAttemptingFullContext d=1 (stat), input='else'\nline 1:19 reportContextSensitivity d=1 (stat), input='else'\nline 2:27 reportAttemptingFullContext d=1 (stat), input='else'\nline 2:36 reportAmbiguity d=1 (stat): ambigAlts={1, 2}, input='elsefoo}'\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "token:{", "enter:stat", "token:if", "token:x", "token:then", "enter:stat",
    "token:return", "exit:stat", "token:else", "token:foo", "exit:stat", "enter:stat",
    "token:if", "token:x", "token:then", "enter:stat", "token:if", "token:y", "token:then",
    "enter:stat", "token:return", "exit:stat", "token:else", "token:foo", "exit:stat",
    "exit:stat", "token:}", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "{", 0, 1, 1, 0, 0),
      (3, "if", 2, 4, 1, 2, 0),
      (7, "x", 5, 6, 1, 5, 0),
      (4, "then", 7, 11, 1, 7, 0),
      (6, "return", 12, 18, 1, 12, 0),
      (5, "else", 19, 23, 1, 19, 0),
      (7, "foo", 24, 27, 1, 24, 0),
      (3, "if", 28, 30, 2, 0, 0),
      (7, "x", 31, 32, 2, 3, 0),
      (4, "then", 33, 37, 2, 5, 0),
      (3, "if", 38, 40, 2, 10, 0),
      (7, "y", 41, 42, 2, 13, 0),
      (4, "then", 43, 47, 2, 15, 0),
      (6, "return", 48, 54, 2, 20, 0),
      (5, "else", 55, 59, 2, 27, 0),
      (7, "foo", 60, 63, 2, 32, 0),
      (2, "}", 64, 65, 2, 36, 0),
      (-1, "<EOF>", 66, 66, 3, 0, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream FullContextParsing FullContextIF_THEN_ELSEParse_6" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          event.control.unwrap().prediction_mode = @runtime.LL_EXACT_AMBIG_DETECTION
        1 => printed.write_string(event.control.unwrap().dump_dfa())
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u029.grammar()
  let parsed = grammar.parse_default(
    "{ if x then return else foo\nif x then if y then return else foo }\n",
    report_prediction=true,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 0), (1, 66)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s \"{\" (stat \"if\" \"x\" \"then\" (stat \"return\") \"else\" \"foo\") (stat \"if\" \"x\" \"then\" (stat \"if\" \"y\" \"then\" (stat \"return\") \"else\" \"foo\")) \"}\")",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(19)),
    (Some(1), Some(19)),
    (Some(2), Some(27)),
    (Some(2), Some(36)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering(
    "{ if x then return else foo\nif x then if y then return else foo }\n",
    lexer_action=(_, _) => (),
  )
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(
    parsed.context.get_text(),
    "{ifxthenreturnelsefooifxthenifythenreturnelsefoo}",
  )
  assert_eq(
    printed.to_string(),
    "Decision 1:\ns0-'}'->:s2=>2\ns0-'else'->:s1^=>1\n",
  )
  let expected_prediction : Json = [
    {
      "kind": "attempting_full_context",
      "decision": 1,
      "start": 19,
      "stop": 19,
      "exact": false,
      "alternatives": [1, 2],
      "prediction": 0,
    },
    {
      "kind": "context_sensitivity",
      "decision": 1,
      "start": 19,
      "stop": 19,
      "exact": false,
      "alternatives": [],
      "prediction": 1,
    },
    {
      "kind": "attempting_full_context",
      "decision": 1,
      "start": 55,
      "stop": 55,
      "exact": false,
      "alternatives": [1, 2],
      "prediction": 0,
    },
    {
      "kind": "ambiguity",
      "decision": 1,
      "start": 55,
      "stop": 64,
      "exact": true,
      "alternatives": [1, 2],
      "prediction": 0,
    },
  ]
  @debug.assert_eq(
    Json::array(parsed.prediction_events.map(event => event.to_json())),
    expected_prediction,
  )
  assert_eq(
    parsed.diagnostics
    .filter(d => d.code.has_prefix("prediction_"))
    .map(d => {
      "line " +
      d.line.unwrap().to_string() +
      ":" +
      d.column.unwrap().to_string() +
      " " +
      d.message +
      "\n"
    })
    .join(""),
    "line 1:19 reportAttemptingFullContext d=1 (stat), input='else'\nline 1:19 reportContextSensitivity d=1 (stat), input='else'\nline 2:27 reportAttemptingFullContext d=1 (stat), input='else'\nline 2:36 reportAmbiguity d=1 (stat): ambigAlts={1, 2}, input='elsefoo}'\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "token:{", "enter:stat", "token:if", "token:x", "token:then", "enter:stat",
    "token:return", "exit:stat", "token:else", "token:foo", "exit:stat", "enter:stat",
    "token:if", "token:x", "token:then", "enter:stat", "token:if", "token:y", "token:then",
    "enter:stat", "token:return", "exit:stat", "token:else", "token:foo", "exit:stat",
    "exit:stat", "token:}", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "{", 0, 1, 1, 0, 0),
      (3, "if", 2, 4, 1, 2, 0),
      (7, "x", 5, 6, 1, 5, 0),
      (4, "then", 7, 11, 1, 7, 0),
      (6, "return", 12, 18, 1, 12, 0),
      (5, "else", 19, 23, 1, 19, 0),
      (7, "foo", 24, 27, 1, 24, 0),
      (3, "if", 28, 30, 2, 0, 0),
      (7, "x", 31, 32, 2, 3, 0),
      (4, "then", 33, 37, 2, 5, 0),
      (3, "if", 38, 40, 2, 10, 0),
      (7, "y", 41, 42, 2, 13, 0),
      (4, "then", 43, 47, 2, 15, 0),
      (6, "return", 48, 54, 2, 20, 0),
      (5, "else", 55, 59, 2, 27, 0),
      (7, "foo", 60, 63, 2, 32, 0),
      (2, "}", 64, 65, 2, 36, 0),
      (-1, "<EOF>", 66, 66, 3, 0, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream FullContextParsing LoopsSimulateTailRecursion" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("fail." + "\n")
        1 =>
          printed.write_string(
            "pass: " +
            observed_text(event, observed_context(event, "expr", []), false) +
            "\n",
          )
        2 =>
          event.control.unwrap().prediction_mode = @runtime.LL_EXACT_AMBIG_DETECTION
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u030.grammar()
  let parsed = grammar.parse_default(
    "a(i)<-x",
    report_prediction=true,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(2, 0), (1, 7)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(prog (expr_or_assign (expr (expr_primary \"a\" \"(\" \"i\" \")\") \"<-\" \"x\")))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(3)),
    (Some(1), Some(7)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a(i)<-x", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a(i)<-x")
  assert_eq(printed.to_string(), "pass: a(i)<-x\n")
  let expected_prediction : Json = [
    {
      "kind": "attempting_full_context",
      "decision": 3,
      "start": 0,
      "stop": 3,
      "exact": false,
      "alternatives": [2, 3],
      "prediction": 0,
    },
    {
      "kind": "ambiguity",
      "decision": 3,
      "start": 0,
      "stop": 7,
      "exact": true,
      "alternatives": [2, 3],
      "prediction": 0,
    },
  ]
  @debug.assert_eq(
    Json::array(parsed.prediction_events.map(event => event.to_json())),
    expected_prediction,
  )
  assert_eq(
    parsed.diagnostics
    .filter(d => d.code.has_prefix("prediction_"))
    .map(d => {
      "line " +
      d.line.unwrap().to_string() +
      ":" +
      d.column.unwrap().to_string() +
      " " +
      d.message +
      "\n"
    })
    .join(""),
    "line 1:3 reportAttemptingFullContext d=3 (expr_primary), input='a(i)'\nline 1:7 reportAmbiguity d=3 (expr_primary): ambigAlts={2, 3}, input='a(i)<-x'\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:prog", "enter:expr_or_assign", "enter:expr", "enter:expr_primary", "token:a",
    "token:(", "token:i", "token:)", "exit:expr_primary", "token:<-", "token:x",
    "exit:expr", "exit:expr_or_assign", "exit:prog",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (5, "a", 0, 1, 1, 0, 0),
      (3, "(", 1, 2, 1, 1, 0),
      (5, "i", 2, 3, 1, 2, 0),
      (4, ")", 3, 4, 1, 3, 0),
      (2, "<-", 4, 6, 1, 4, 0),
      (5, "x", 6, 7, 1, 6, 0),
      (-1, "<EOF>", 7, 7, 1, 7, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream FullContextParsing SLLSeesEOFInLLGrammar" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(event.control.unwrap().dump_dfa())
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u031.grammar()
  let parsed = grammar.parse_default(
    "34 abc",
    report_prediction=true,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 6)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a (e \"34\") \"abc\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(3)),
    (Some(1), Some(0)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("34 abc", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "34abc")
  assert_eq(printed.to_string(), "Decision 0:\ns0-INT->s1\ns1-ID->:s2^=>1\n")
  let expected_prediction : Json = [
    {
      "kind": "attempting_full_context",
      "decision": 0,
      "start": 0,
      "stop": 3,
      "exact": false,
      "alternatives": [1, 2],
      "prediction": 0,
    },
    {
      "kind": "context_sensitivity",
      "decision": 0,
      "start": 0,
      "stop": 0,
      "exact": false,
      "alternatives": [],
      "prediction": 1,
    },
  ]
  @debug.assert_eq(
    Json::array(parsed.prediction_events.map(event => event.to_json())),
    expected_prediction,
  )
  assert_eq(
    parsed.diagnostics
    .filter(d => d.code.has_prefix("prediction_"))
    .map(d => {
      "line " +
      d.line.unwrap().to_string() +
      ":" +
      d.column.unwrap().to_string() +
      " " +
      d.message +
      "\n"
    })
    .join(""),
    "line 1:3 reportAttemptingFullContext d=0 (e), input='34abc'\nline 1:0 reportContextSensitivity d=0 (e), input='34'\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "enter:e", "token:34", "exit:e", "token:abc", "exit:a",
    "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "34", 0, 2, 1, 0, 0),
      (1, "abc", 3, 6, 1, 3, 0),
      (-1, "<EOF>", 6, 6, 1, 6, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion AmbigLR_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u032.grammar()
  let parsed = grammar.parse_default(
    "1\n",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(prog (stat (expr \"1\") \"\\n\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("1\n", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "1\n")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:prog", "enter:stat", "enter:expr", "token:1", "exit:expr", "token:\n",
    "exit:stat", "exit:prog",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (9, "1", 0, 1, 1, 0, 0),
      (10, "\n", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 2, 0, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion AmbigLR_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u033.grammar()
  let parsed = grammar.parse_default(
    "a = 5\n",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(prog (stat \"a\" \"=\" (expr \"5\") \"\\n\"))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a = 5\n", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a=5\n")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:prog", "enter:stat", "token:a", "token:=", "enter:expr", "token:5", "exit:expr",
    "token:\n", "exit:stat", "exit:prog",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (8, "a", 0, 1, 1, 0, 0),
      (1, "=", 2, 3, 1, 2, 0),
      (9, "5", 4, 5, 1, 4, 0),
      (10, "\n", 5, 6, 1, 5, 0),
      (-1, "<EOF>", 6, 6, 2, 0, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion AmbigLR_3" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u034.grammar()
  let parsed = grammar.parse_default(
    "b = 6\n",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(prog (stat \"b\" \"=\" (expr \"6\") \"\\n\"))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("b = 6\n", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "b=6\n")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:prog", "enter:stat", "token:b", "token:=", "enter:expr", "token:6", "exit:expr",
    "token:\n", "exit:stat", "exit:prog",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (8, "b", 0, 1, 1, 0, 0),
      (1, "=", 2, 3, 1, 2, 0),
      (9, "6", 4, 5, 1, 4, 0),
      (10, "\n", 5, 6, 1, 5, 0),
      (-1, "<EOF>", 6, 6, 2, 0, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion AmbigLR_4" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u035.grammar()
  let parsed = grammar.parse_default(
    "a+b*2\n",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(prog (stat (expr (expr \"a\") \"+\" (expr (expr \"b\") \"*\" (expr \"2\"))) \"\\n\"))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a+b*2\n", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a+b*2\n")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:prog", "enter:stat", "enter:expr", "enter:expr", "token:a", "exit:expr",
    "token:+", "enter:expr", "enter:expr", "token:b", "exit:expr", "token:*", "enter:expr",
    "token:2", "exit:expr", "exit:expr", "exit:expr", "token:\n", "exit:stat", "exit:prog",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (8, "a", 0, 1, 1, 0, 0),
      (6, "+", 1, 2, 1, 1, 0),
      (8, "b", 2, 3, 1, 2, 0),
      (4, "*", 3, 4, 1, 3, 0),
      (9, "2", 4, 5, 1, 4, 0),
      (10, "\n", 5, 6, 1, 5, 0),
      (-1, "<EOF>", 6, 6, 2, 0, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion AmbigLR_5" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u036.grammar()
  let parsed = grammar.parse_default(
    "(1+2)*3\n",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(prog (stat (expr (expr \"(\" (expr (expr \"1\") \"+\" (expr \"2\")) \")\") \"*\" (expr \"3\")) \"\\n\"))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("(1+2)*3\n", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]},{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "(1+2)*3\n")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:prog", "enter:stat", "enter:expr", "enter:expr", "token:(", "enter:expr",
    "enter:expr", "token:1", "exit:expr", "token:+", "enter:expr", "token:2", "exit:expr",
    "exit:expr", "token:)", "exit:expr", "token:*", "enter:expr", "token:3", "exit:expr",
    "exit:expr", "token:\n", "exit:stat", "exit:prog",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "(", 0, 1, 1, 0, 0),
      (9, "1", 1, 2, 1, 1, 0),
      (6, "+", 2, 3, 1, 2, 0),
      (9, "2", 3, 4, 1, 3, 0),
      (3, ")", 4, 5, 1, 4, 0),
      (4, "*", 5, 6, 1, 5, 0),
      (9, "3", 6, 7, 1, 6, 0),
      (10, "\n", 7, 8, 1, 7, 0),
      (-1, "<EOF>", 8, 8, 2, 0, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion Declarations_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u037.grammar()
  let parsed = grammar.parse_default(
    "a",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (declarator \"a\") <EOF>)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a<EOF>")
  assert_eq(printed.to_string(), "(s (declarator a) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:declarator", "token:a", "exit:declarator", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(6, "a", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion Declarations_10" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u038.grammar()
  let parsed = grammar.parse_default(
    "(*a)[]",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 6)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (declarator (declarator \"(\" (declarator \"*\" (declarator \"a\")) \")\") \"[\" \"]\") <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("(*a)[]", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "(*a)[]<EOF>")
  assert_eq(
    printed.to_string(),
    "(s (declarator (declarator ( (declarator * (declarator a)) )) [ ]) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:declarator", "enter:declarator", "token:(", "enter:declarator",
    "token:*", "enter:declarator", "token:a", "exit:declarator", "exit:declarator",
    "token:)", "exit:declarator", "token:[", "token:]", "exit:declarator", "token:<EOF>",
    "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "(", 0, 1, 1, 0, 0),
      (5, "*", 1, 2, 1, 1, 0),
      (6, "a", 2, 3, 1, 2, 0),
      (4, ")", 3, 4, 1, 3, 0),
      (1, "[", 4, 5, 1, 4, 0),
      (2, "]", 5, 6, 1, 5, 0),
      (-1, "<EOF>", 6, 6, 1, 6, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion Declarations_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u039.grammar()
  let parsed = grammar.parse_default(
    "*a",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 2)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (declarator \"*\" (declarator \"a\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("*a", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "*a<EOF>")
  assert_eq(printed.to_string(), "(s (declarator * (declarator a)) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:declarator", "token:*", "enter:declarator", "token:a", "exit:declarator",
    "exit:declarator", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (5, "*", 0, 1, 1, 0, 0),
      (6, "a", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion Declarations_3" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u040.grammar()
  let parsed = grammar.parse_default(
    "**a",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (declarator \"*\" (declarator \"*\" (declarator \"a\"))) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("**a", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "**a<EOF>")
  assert_eq(
    printed.to_string(),
    "(s (declarator * (declarator * (declarator a))) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:declarator", "token:*", "enter:declarator", "token:*", "enter:declarator",
    "token:a", "exit:declarator", "exit:declarator", "exit:declarator", "token:<EOF>",
    "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (5, "*", 0, 1, 1, 0, 0),
      (5, "*", 1, 2, 1, 1, 0),
      (6, "a", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion Declarations_4" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u041.grammar()
  let parsed = grammar.parse_default(
    "a[3]",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 4)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (declarator (declarator \"a\") \"[\" (e \"3\") \"]\") <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a[3]", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a[3]<EOF>")
  assert_eq(
    printed.to_string(),
    "(s (declarator (declarator a) [ (e 3) ]) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:declarator", "enter:declarator", "token:a", "exit:declarator",
    "token:[", "enter:e", "token:3", "exit:e", "token:]", "exit:declarator", "token:<EOF>",
    "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "a", 0, 1, 1, 0, 0),
      (1, "[", 1, 2, 1, 1, 0),
      (7, "3", 2, 3, 1, 2, 0),
      (2, "]", 3, 4, 1, 3, 0),
      (-1, "<EOF>", 4, 4, 1, 4, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion Declarations_5" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u042.grammar()
  let parsed = grammar.parse_default(
    "b[]",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (declarator (declarator \"b\") \"[\" \"]\") <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("b[]", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "b[]<EOF>")
  assert_eq(printed.to_string(), "(s (declarator (declarator b) [ ]) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:declarator", "enter:declarator", "token:b", "exit:declarator",
    "token:[", "token:]", "exit:declarator", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "b", 0, 1, 1, 0, 0),
      (1, "[", 1, 2, 1, 1, 0),
      (2, "]", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion Declarations_6" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u043.grammar()
  let parsed = grammar.parse_default(
    "(a)",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (declarator \"(\" (declarator \"a\") \")\") <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("(a)", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "(a)<EOF>")
  assert_eq(printed.to_string(), "(s (declarator ( (declarator a) )) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:declarator", "token:(", "enter:declarator", "token:a", "exit:declarator",
    "token:)", "exit:declarator", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "(", 0, 1, 1, 0, 0),
      (6, "a", 1, 2, 1, 1, 0),
      (4, ")", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion Declarations_7" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u044.grammar()
  let parsed = grammar.parse_default(
    "a[]()",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (declarator (declarator (declarator \"a\") \"[\" \"]\") \"(\" \")\") <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a[]()", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a[]()<EOF>")
  assert_eq(
    printed.to_string(),
    "(s (declarator (declarator (declarator a) [ ]) ( )) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:declarator", "enter:declarator", "enter:declarator", "token:a",
    "exit:declarator", "token:[", "token:]", "exit:declarator", "token:(", "token:)",
    "exit:declarator", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "a", 0, 1, 1, 0, 0),
      (1, "[", 1, 2, 1, 1, 0),
      (2, "]", 2, 3, 1, 2, 0),
      (3, "(", 3, 4, 1, 3, 0),
      (4, ")", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion Declarations_8" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u045.grammar()
  let parsed = grammar.parse_default(
    "a[][]",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (declarator (declarator (declarator \"a\") \"[\" \"]\") \"[\" \"]\") <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a[][]", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a[][]<EOF>")
  assert_eq(
    printed.to_string(),
    "(s (declarator (declarator (declarator a) [ ]) [ ]) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:declarator", "enter:declarator", "enter:declarator", "token:a",
    "exit:declarator", "token:[", "token:]", "exit:declarator", "token:[", "token:]",
    "exit:declarator", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "a", 0, 1, 1, 0, 0),
      (1, "[", 1, 2, 1, 1, 0),
      (2, "]", 2, 3, 1, 2, 0),
      (1, "[", 3, 4, 1, 3, 0),
      (2, "]", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion Declarations_9" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u046.grammar()
  let parsed = grammar.parse_default(
    "*a[]",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 4)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (declarator \"*\" (declarator (declarator \"a\") \"[\" \"]\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("*a[]", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "*a[]<EOF>")
  assert_eq(
    printed.to_string(),
    "(s (declarator * (declarator (declarator a) [ ])) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:declarator", "token:*", "enter:declarator", "enter:declarator",
    "token:a", "exit:declarator", "token:[", "token:]", "exit:declarator", "exit:declarator",
    "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (5, "*", 0, 1, 1, 0, 0),
      (6, "a", 1, 2, 1, 1, 0),
      (1, "[", 2, 3, 1, 2, 0),
      (2, "]", 3, 4, 1, 3, 0),
      (-1, "<EOF>", 4, 4, 1, 4, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion DirectCallToLeftRecursiveRule_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u047.grammar()
  let parsed = grammar.parse_default(
    "x",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"x\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "x")
  assert_eq(printed.to_string(), "(a x)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:x", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "x", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion DirectCallToLeftRecursiveRule_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u048.grammar()
  let parsed = grammar.parse_default(
    "x y",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(a (a \"x\") \"y\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x y", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "xy")
  assert_eq(printed.to_string(), "(a (a x) y)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "enter:a", "token:x", "exit:a", "token:y", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "x", 0, 1, 1, 0, 0),
      (1, "y", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion DirectCallToLeftRecursiveRule_3" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u049.grammar()
  let parsed = grammar.parse_default(
    "x y z",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(parsed.tree.to_sexpr(), "(a (a (a \"x\") \"y\") \"z\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x y z", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "xyz")
  assert_eq(printed.to_string(), "(a (a (a x) y) z)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "enter:a", "enter:a", "token:x", "exit:a", "token:y", "exit:a", "token:z",
    "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "x", 0, 1, 1, 0, 0),
      (1, "y", 2, 3, 1, 2, 0),
      (1, "z", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion Expressions_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u050.grammar()
  let parsed = grammar.parse_default(
    "a",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e \"a\") <EOF>)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a<EOF>")
  assert_eq(printed.to_string(), "(s (e a) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "token:a", "exit:e", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(6, "a", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion Expressions_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u051.grammar()
  let parsed = grammar.parse_default(
    "1",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e \"1\") <EOF>)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("1", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "1<EOF>")
  assert_eq(printed.to_string(), "(s (e 1) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "token:1", "exit:e", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(7, "1", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion Expressions_3" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u052.grammar()
  let parsed = grammar.parse_default(
    "a-1",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e (e \"a\") \"-\" (e \"1\")) <EOF>)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a-1", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a-1<EOF>")
  assert_eq(printed.to_string(), "(s (e (e a) - (e 1)) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "exit:e", "token:-", "enter:e", "token:1",
    "exit:e", "exit:e", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "a", 0, 1, 1, 0, 0),
      (3, "-", 1, 2, 1, 1, 0),
      (7, "1", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion Expressions_4" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u053.grammar()
  let parsed = grammar.parse_default(
    "a.b",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e (e \"a\") \".\" \"b\") <EOF>)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a.b", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a.b<EOF>")
  assert_eq(printed.to_string(), "(s (e (e a) . b) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "exit:e", "token:.", "token:b", "exit:e",
    "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "a", 0, 1, 1, 0, 0),
      (1, ".", 1, 2, 1, 1, 0),
      (6, "b", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion Expressions_5" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u054.grammar()
  let parsed = grammar.parse_default(
    "a.this",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 6)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e (e \"a\") \".\" \"this\") <EOF>)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a.this", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a.this<EOF>")
  assert_eq(printed.to_string(), "(s (e (e a) . this) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "exit:e", "token:.", "token:this",
    "exit:e", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "a", 0, 1, 1, 0, 0),
      (1, ".", 1, 2, 1, 1, 0),
      (2, "this", 2, 6, 1, 2, 0),
      (-1, "<EOF>", 6, 6, 1, 6, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion Expressions_6" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u055.grammar()
  let parsed = grammar.parse_default(
    "-a",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 2)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e \"-\" (e \"a\")) <EOF>)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("-a", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "-a<EOF>")
  assert_eq(printed.to_string(), "(s (e - (e a)) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "token:-", "enter:e", "token:a", "exit:e", "exit:e", "token:<EOF>",
    "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "-", 0, 1, 1, 0, 0),
      (6, "a", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion Expressions_7" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u056.grammar()
  let parsed = grammar.parse_default(
    "-a+b",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 4)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"-\" (e \"a\")) \"+\" (e \"b\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("-a+b", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "-a+b<EOF>")
  assert_eq(printed.to_string(), "(s (e (e - (e a)) + (e b)) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:-", "enter:e", "token:a", "exit:e", "exit:e",
    "token:+", "enter:e", "token:b", "exit:e", "exit:e", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "-", 0, 1, 1, 0, 0),
      (6, "a", 1, 2, 1, 1, 0),
      (5, "+", 2, 3, 1, 2, 0),
      (6, "b", 3, 4, 1, 3, 0),
      (-1, "<EOF>", 4, 4, 1, 4, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion JavaExpressions_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u057.grammar()
  let parsed = grammar.parse_default(
    "a|b&c",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"a\") \"|\" (e (e \"b\") \"&\" (e \"c\"))) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a|b&c", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a|b&c<EOF>")
  assert_eq(printed.to_string(), "(s (e (e a) | (e (e b) & (e c))) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "exit:e", "token:|", "enter:e", "enter:e",
    "token:b", "exit:e", "token:&", "enter:e", "token:c", "exit:e", "exit:e", "exit:e",
    "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (50, "a", 0, 1, 1, 0, 0),
      (32, "|", 1, 2, 1, 1, 0),
      (50, "b", 2, 3, 1, 2, 0),
      (30, "&", 3, 4, 1, 3, 0),
      (50, "c", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion JavaExpressions_10" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u058.grammar()
  let parsed = grammar.parse_default(
    "a.f(x)==T.c",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 11)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e (e (e \"a\") \".\" \"f\") \"(\" (expressionList (e \"x\")) \")\") \"==\" (e (e \"T\") \".\" \"c\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a.f(x)==T.c", lexer_action=(_, _) => {
    ()
  })
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a.f(x)==T.c<EOF>")
  assert_eq(
    printed.to_string(),
    "(s (e (e (e (e a) . f) ( (expressionList (e x)) )) == (e (e T) . c)) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "enter:e", "enter:e", "token:a", "exit:e", "token:.",
    "token:f", "exit:e", "token:(", "enter:expressionList", "enter:e", "token:x",
    "exit:e", "exit:expressionList", "token:)", "exit:e", "token:==", "enter:e",
    "enter:e", "token:T", "exit:e", "token:.", "token:c", "exit:e", "exit:e", "token:<EOF>",
    "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (50, "a", 0, 1, 1, 0, 0),
      (6, ".", 1, 2, 1, 1, 0),
      (50, "f", 2, 3, 1, 2, 0),
      (2, "(", 3, 4, 1, 3, 0),
      (50, "x", 4, 5, 1, 4, 0),
      (3, ")", 5, 6, 1, 5, 0),
      (28, "==", 6, 8, 1, 6, 0),
      (50, "T", 8, 9, 1, 8, 0),
      (6, ".", 9, 10, 1, 9, 0),
      (50, "c", 10, 11, 1, 10, 0),
      (-1, "<EOF>", 11, 11, 1, 11, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion JavaExpressions_11" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u059.grammar()
  let parsed = grammar.parse_default(
    "a.f().g(x,1)",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 12)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e (e (e (e \"a\") \".\" \"f\") \"(\" \")\") \".\" \"g\") \"(\" (expressionList (e \"x\") \",\" (e \"1\")) \")\") <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a.f().g(x,1)", lexer_action=(_, _) => {
    ()
  })
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a.f().g(x,1)<EOF>")
  assert_eq(
    printed.to_string(),
    "(s (e (e (e (e (e a) . f) ( )) . g) ( (expressionList (e x) , (e 1)) )) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "enter:e", "enter:e", "enter:e", "token:a",
    "exit:e", "token:.", "token:f", "exit:e", "token:(", "token:)", "exit:e", "token:.",
    "token:g", "exit:e", "token:(", "enter:expressionList", "enter:e", "token:x",
    "exit:e", "token:,", "enter:e", "token:1", "exit:e", "exit:expressionList", "token:)",
    "exit:e", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (50, "a", 0, 1, 1, 0, 0),
      (6, ".", 1, 2, 1, 1, 0),
      (50, "f", 2, 3, 1, 2, 0),
      (2, "(", 3, 4, 1, 3, 0),
      (3, ")", 4, 5, 1, 4, 0),
      (6, ".", 5, 6, 1, 5, 0),
      (50, "g", 6, 7, 1, 6, 0),
      (2, "(", 7, 8, 1, 7, 0),
      (50, "x", 8, 9, 1, 8, 0),
      (1, ",", 9, 10, 1, 9, 0),
      (51, "1", 10, 11, 1, 10, 0),
      (3, ")", 11, 12, 1, 11, 0),
      (-1, "<EOF>", 12, 12, 1, 12, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion JavaExpressions_12" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u060.grammar()
  let parsed = grammar.parse_default(
    "new T[((n-1) * x) + 1]",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 22)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e \"new\" (typespec \"T\") \"[\" (e (e \"(\" (e (e \"(\" (e (e \"n\") \"-\" (e \"1\")) \")\") \"*\" (e \"x\")) \")\") \"+\" (e \"1\")) \"]\") <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("new T[((n-1) * x) + 1]", lexer_action=(
    _,
    _,
  ) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]},{\"values\":{},\"children\":[]}]}]},{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "newT[((n-1)*x)+1]<EOF>")
  assert_eq(
    printed.to_string(),
    "(s (e new (typespec T) [ (e (e ( (e (e ( (e (e n) - (e 1)) )) * (e x)) )) + (e 1)) ]) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "token:new", "enter:typespec", "token:T", "exit:typespec",
    "token:[", "enter:e", "enter:e", "token:(", "enter:e", "enter:e", "token:(",
    "enter:e", "enter:e", "token:n", "exit:e", "token:-", "enter:e", "token:1", "exit:e",
    "exit:e", "token:)", "exit:e", "token:*", "enter:e", "token:x", "exit:e", "exit:e",
    "token:)", "exit:e", "token:+", "enter:e", "token:1", "exit:e", "exit:e", "token:]",
    "exit:e", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (8, "new", 0, 3, 1, 0, 0),
      (50, "T", 4, 5, 1, 4, 0),
      (9, "[", 5, 6, 1, 5, 0),
      (2, "(", 6, 7, 1, 6, 0),
      (2, "(", 7, 8, 1, 7, 0),
      (50, "n", 8, 9, 1, 8, 0),
      (14, "-", 9, 10, 1, 9, 0),
      (51, "1", 10, 11, 1, 10, 0),
      (3, ")", 11, 12, 1, 11, 0),
      (17, "*", 13, 14, 1, 13, 0),
      (50, "x", 15, 16, 1, 15, 0),
      (3, ")", 16, 17, 1, 16, 0),
      (13, "+", 18, 19, 1, 18, 0),
      (51, "1", 20, 21, 1, 20, 0),
      (10, "]", 21, 22, 1, 21, 0),
      (-1, "<EOF>", 22, 22, 1, 22, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion JavaExpressions_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u061.grammar()
  let parsed = grammar.parse_default(
    "(a|b)&c",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 7)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"(\" (e (e \"a\") \"|\" (e \"b\")) \")\") \"&\" (e \"c\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("(a|b)&c", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "(a|b)&c<EOF>")
  assert_eq(
    printed.to_string(),
    "(s (e (e ( (e (e a) | (e b)) )) & (e c)) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:(", "enter:e", "enter:e", "token:a",
    "exit:e", "token:|", "enter:e", "token:b", "exit:e", "exit:e", "token:)", "exit:e",
    "token:&", "enter:e", "token:c", "exit:e", "exit:e", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "(", 0, 1, 1, 0, 0),
      (50, "a", 1, 2, 1, 1, 0),
      (32, "|", 2, 3, 1, 2, 0),
      (50, "b", 3, 4, 1, 3, 0),
      (3, ")", 4, 5, 1, 4, 0),
      (30, "&", 5, 6, 1, 5, 0),
      (50, "c", 6, 7, 1, 6, 0),
      (-1, "<EOF>", 7, 7, 1, 7, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion JavaExpressions_3" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u062.grammar()
  let parsed = grammar.parse_default(
    "a > b",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e (e \"a\") \">\" (e \"b\")) <EOF>)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a > b", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a>b<EOF>")
  assert_eq(printed.to_string(), "(s (e (e a) > (e b)) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "exit:e", "token:>", "enter:e", "token:b",
    "exit:e", "exit:e", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (50, "a", 0, 1, 1, 0, 0),
      (25, ">", 2, 3, 1, 2, 0),
      (50, "b", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion JavaExpressions_4" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u063.grammar()
  let parsed = grammar.parse_default(
    "a >> b",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 6)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e (e \"a\") \">>\" (e \"b\")) <EOF>)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a >> b", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a>>b<EOF>")
  assert_eq(printed.to_string(), "(s (e (e a) >> (e b)) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "exit:e", "token:>>", "enter:e",
    "token:b", "exit:e", "exit:e", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (50, "a", 0, 1, 1, 0, 0),
      (22, ">>", 2, 4, 1, 2, 0),
      (50, "b", 5, 6, 1, 5, 0),
      (-1, "<EOF>", 6, 6, 1, 6, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion JavaExpressions_5" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u064.grammar()
  let parsed = grammar.parse_default(
    "a=b=c",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"a\") \"=\" (e (e \"b\") \"=\" (e \"c\"))) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a=b=c", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a=b=c<EOF>")
  assert_eq(printed.to_string(), "(s (e (e a) = (e (e b) = (e c))) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "exit:e", "token:=", "enter:e", "enter:e",
    "token:b", "exit:e", "token:=", "enter:e", "token:c", "exit:e", "exit:e", "exit:e",
    "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (50, "a", 0, 1, 1, 0, 0),
      (37, "=", 1, 2, 1, 1, 0),
      (50, "b", 2, 3, 1, 2, 0),
      (37, "=", 3, 4, 1, 3, 0),
      (50, "c", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion JavaExpressions_6" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u065.grammar()
  let parsed = grammar.parse_default(
    "a^b^c",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"a\") \"^\" (e (e \"b\") \"^\" (e \"c\"))) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a^b^c", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a^b^c<EOF>")
  assert_eq(printed.to_string(), "(s (e (e a) ^ (e (e b) ^ (e c))) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "exit:e", "token:^", "enter:e", "enter:e",
    "token:b", "exit:e", "token:^", "enter:e", "token:c", "exit:e", "exit:e", "exit:e",
    "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (50, "a", 0, 1, 1, 0, 0),
      (31, "^", 1, 2, 1, 1, 0),
      (50, "b", 2, 3, 1, 2, 0),
      (31, "^", 3, 4, 1, 3, 0),
      (50, "c", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion JavaExpressions_7" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u066.grammar()
  let parsed = grammar.parse_default(
    "(T)x",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 4)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e \"(\" (typespec \"T\") \")\" (e \"x\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("(T)x", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "(T)x<EOF>")
  assert_eq(printed.to_string(), "(s (e ( (typespec T) ) (e x)) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "token:(", "enter:typespec", "token:T", "exit:typespec",
    "token:)", "enter:e", "token:x", "exit:e", "exit:e", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "(", 0, 1, 1, 0, 0),
      (50, "T", 1, 2, 1, 1, 0),
      (3, ")", 2, 3, 1, 2, 0),
      (50, "x", 3, 4, 1, 3, 0),
      (-1, "<EOF>", 4, 4, 1, 4, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion JavaExpressions_8" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u067.grammar()
  let parsed = grammar.parse_default(
    "new A().b",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 9)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"new\" (typespec \"A\") \"(\" \")\") \".\" \"b\") <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("new A().b", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "newA().b<EOF>")
  assert_eq(printed.to_string(), "(s (e (e new (typespec A) ( )) . b) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:new", "enter:typespec", "token:A", "exit:typespec",
    "token:(", "token:)", "exit:e", "token:.", "token:b", "exit:e", "token:<EOF>",
    "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (8, "new", 0, 3, 1, 0, 0),
      (50, "A", 4, 5, 1, 4, 0),
      (2, "(", 5, 6, 1, 5, 0),
      (3, ")", 6, 7, 1, 6, 0),
      (6, ".", 7, 8, 1, 7, 0),
      (50, "b", 8, 9, 1, 8, 0),
      (-1, "<EOF>", 9, 9, 1, 9, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion JavaExpressions_9" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u068.grammar()
  let parsed = grammar.parse_default(
    "(T)t.f()",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 8)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"(\" (typespec \"T\") \")\" (e (e \"t\") \".\" \"f\")) \"(\" \")\") <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("(T)t.f()", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "(T)t.f()<EOF>")
  assert_eq(
    printed.to_string(),
    "(s (e (e ( (typespec T) ) (e (e t) . f)) ( )) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:(", "enter:typespec", "token:T", "exit:typespec",
    "token:)", "enter:e", "enter:e", "token:t", "exit:e", "token:.", "token:f", "exit:e",
    "exit:e", "token:(", "token:)", "exit:e", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "(", 0, 1, 1, 0, 0),
      (50, "T", 1, 2, 1, 1, 0),
      (3, ")", 2, 3, 1, 2, 0),
      (50, "t", 3, 4, 1, 3, 0),
      (6, ".", 4, 5, 1, 4, 0),
      (50, "f", 5, 6, 1, 5, 0),
      (2, "(", 6, 7, 1, 6, 0),
      (3, ")", 7, 8, 1, 7, 0),
      (-1, "<EOF>", 8, 8, 1, 8, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion LabelsOnOpSubrule_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        3 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u069.grammar()
  let parsed = grammar.parse_default(
    "4",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(1, 1), (3, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e \"4\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("4", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "4")
  assert_eq(printed.to_string(), "(s (e 4))\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "token:4", "exit:e", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(5, "4", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion LabelsOnOpSubrule_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        3 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u070.grammar()
  let parsed = grammar.parse_default(
    "1*2/3",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(1, 1), (1, 3), (0, 3), (1, 5), (0, 5), (3, 5)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e (e \"1\") \"*\" (e \"2\")) \"/\" (e \"3\")))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("1*2/3", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "1*2/3")
  assert_eq(printed.to_string(), "(s (e (e (e 1) * (e 2)) / (e 3)))\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "enter:e", "token:1", "exit:e", "token:*", "enter:e",
    "token:2", "exit:e", "exit:e", "token:/", "enter:e", "token:3", "exit:e", "exit:e",
    "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (5, "1", 0, 1, 1, 0, 0),
      (1, "*", 1, 2, 1, 1, 0),
      (5, "2", 2, 3, 1, 2, 0),
      (2, "/", 3, 4, 1, 3, 0),
      (5, "3", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion LabelsOnOpSubrule_3" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        3 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u071.grammar()
  let parsed = grammar.parse_default(
    "(1/2)*3",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [
    (1, 2),
    (1, 4),
    (0, 4),
    (2, 5),
    (1, 7),
    (0, 7),
    (3, 7),
  ])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"(\" (e (e \"1\") \"/\" (e \"2\")) \")\") \"*\" (e \"3\")))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("(1/2)*3", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "(1/2)*3")
  assert_eq(printed.to_string(), "(s (e (e ( (e (e 1) / (e 2)) )) * (e 3)))\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:(", "enter:e", "enter:e", "token:1",
    "exit:e", "token:/", "enter:e", "token:2", "exit:e", "exit:e", "token:)", "exit:e",
    "token:*", "enter:e", "token:3", "exit:e", "exit:e", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "(", 0, 1, 1, 0, 0),
      (5, "1", 1, 2, 1, 1, 0),
      (2, "/", 2, 3, 1, 2, 0),
      (5, "2", 3, 4, 1, 3, 0),
      (4, ")", 4, 5, 1, 4, 0),
      (1, "*", 5, 6, 1, 5, 0),
      (5, "3", 6, 7, 1, 6, 0),
      (-1, "<EOF>", 7, 7, 1, 7, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion MultipleActions_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        6 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u072.grammar()
  let parsed = grammar.parse_default(
    "4",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(2, 1), (3, 1), (6, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e \"4\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("4", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "4")
  assert_eq(printed.to_string(), "(s (e 4))\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "token:4", "exit:e", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(5, "4", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion MultipleActions_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        6 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u073.grammar()
  let parsed = grammar.parse_default(
    "1*2/3",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [
    (2, 1),
    (3, 1),
    (2, 3),
    (3, 3),
    (0, 3),
    (1, 3),
    (2, 5),
    (3, 5),
    (0, 5),
    (1, 5),
    (6, 5),
  ])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e (e \"1\") \"*\" (e \"2\")) \"/\" (e \"3\")))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("1*2/3", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "1*2/3")
  assert_eq(printed.to_string(), "(s (e (e (e 1) * (e 2)) / (e 3)))\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "enter:e", "token:1", "exit:e", "token:*", "enter:e",
    "token:2", "exit:e", "exit:e", "token:/", "enter:e", "token:3", "exit:e", "exit:e",
    "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (5, "1", 0, 1, 1, 0, 0),
      (1, "*", 1, 2, 1, 1, 0),
      (5, "2", 2, 3, 1, 2, 0),
      (2, "/", 3, 4, 1, 3, 0),
      (5, "3", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion MultipleActions_3" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        6 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u074.grammar()
  let parsed = grammar.parse_default(
    "(1/2)*3",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [
    (2, 2),
    (3, 2),
    (2, 4),
    (3, 4),
    (0, 4),
    (1, 4),
    (4, 5),
    (5, 5),
    (2, 7),
    (3, 7),
    (0, 7),
    (1, 7),
    (6, 7),
  ])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"(\" (e (e \"1\") \"/\" (e \"2\")) \")\") \"*\" (e \"3\")))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("(1/2)*3", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "(1/2)*3")
  assert_eq(printed.to_string(), "(s (e (e ( (e (e 1) / (e 2)) )) * (e 3)))\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:(", "enter:e", "enter:e", "token:1",
    "exit:e", "token:/", "enter:e", "token:2", "exit:e", "exit:e", "token:)", "exit:e",
    "token:*", "enter:e", "token:3", "exit:e", "exit:e", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "(", 0, 1, 1, 0, 0),
      (5, "1", 1, 2, 1, 1, 0),
      (2, "/", 2, 3, 1, 2, 0),
      (5, "2", 3, 4, 1, 3, 0),
      (4, ")", 4, 5, 1, 4, 0),
      (1, "*", 5, 6, 1, 5, 0),
      (5, "3", 6, 7, 1, 6, 0),
      (-1, "<EOF>", 7, 7, 1, 7, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion MultipleActionsPredicatesOptions_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        1 => true
        3 => true
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        6 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u075.grammar()
  let parsed = grammar.parse_default(
    "4",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(2, 1), (3, 1), (6, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e \"4\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("4", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "4")
  assert_eq(printed.to_string(), "(s (e 4))\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "token:4", "exit:e", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(7, "4", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion MultipleActionsPredicatesOptions_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        1 => true
        3 => true
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        6 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u076.grammar()
  let parsed = grammar.parse_default(
    "1*2/3",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [
    (2, 1),
    (3, 1),
    (2, 3),
    (3, 3),
    (0, 3),
    (2, 5),
    (3, 5),
    (0, 5),
    (6, 5),
  ])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e (e \"1\") \"*\" (e \"2\")) \"/\" (e \"3\")))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("1*2/3", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "1*2/3")
  assert_eq(printed.to_string(), "(s (e (e (e 1) * (e 2)) / (e 3)))\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "enter:e", "token:1", "exit:e", "token:*", "enter:e",
    "token:2", "exit:e", "exit:e", "token:/", "enter:e", "token:3", "exit:e", "exit:e",
    "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (7, "1", 0, 1, 1, 0, 0),
      (1, "*", 1, 2, 1, 1, 0),
      (7, "2", 2, 3, 1, 2, 0),
      (2, "/", 3, 4, 1, 3, 0),
      (7, "3", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion MultipleActionsPredicatesOptions_3" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        1 => true
        3 => true
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        6 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u077.grammar()
  let parsed = grammar.parse_default(
    "(1/2)*3",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [
    (2, 2),
    (3, 2),
    (2, 4),
    (3, 4),
    (0, 4),
    (4, 5),
    (5, 5),
    (2, 7),
    (3, 7),
    (0, 7),
    (6, 7),
  ])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"(\" (e (e \"1\") \"/\" (e \"2\")) \")\") \"*\" (e \"3\")))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("(1/2)*3", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "(1/2)*3")
  assert_eq(printed.to_string(), "(s (e (e ( (e (e 1) / (e 2)) )) * (e 3)))\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:(", "enter:e", "enter:e", "token:1",
    "exit:e", "token:/", "enter:e", "token:2", "exit:e", "exit:e", "token:)", "exit:e",
    "token:*", "enter:e", "token:3", "exit:e", "exit:e", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (5, "(", 0, 1, 1, 0, 0),
      (7, "1", 1, 2, 1, 1, 0),
      (2, "/", 2, 3, 1, 2, 0),
      (7, "2", 3, 4, 1, 3, 0),
      (6, ")", 4, 5, 1, 4, 0),
      (1, "*", 5, 6, 1, 5, 0),
      (7, "3", 6, 7, 1, 6, 0),
      (-1, "<EOF>", 7, 7, 1, 7, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion MultipleAlternativesWithCommonLabel_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    enter: (rule, frame) => {
      if rule == 1 && !frame.values.contains("v") {
        frame.values["v"] = Json::number(0.0)
      }
      frame
    },
    wrap: (rule, previous) => {
      let values : Map[String, Json] = Map([])
      if rule == 1 && !values.contains("v") {
        values["v"] = Json::number(0.0)
      }
      { values, shared: previous.shared.copy(), children: [previous], }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(
            bound_int(bound_rule(event, "e", -1).values, "v").to_string() + "\n",
          )
        1 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_rule(event, "e", 0).values, "v") *
            bound_int(bound_rule(event, "e", 1).values, "v")).to_double(),
          )
        2 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_rule(event, "e", 0).values, "v") +
            bound_int(bound_rule(event, "e", 1).values, "v")).to_double(),
          )
        3 =>
          event.frame.values["v"] = Json::number(
            bound_token_int(event, 6).to_double(),
          )
        4 =>
          event.frame.values["v"] = Json::number(
            bound_int(bound_rule(event, "e", -1).values, "v").to_double(),
          )
        5 => {
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") + 1).to_double(),
          )
          if event.context.tokens(7).is_empty() {
            raise @runtime.InvalidArgument("missing asserted token INC")
          }
        }
        6 => {
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") - 1).to_double(),
          )
          if event.context.tokens(8).is_empty() {
            raise @runtime.InvalidArgument("missing asserted token DEC")
          }
        }
        7 => event.frame.values["v"] = Json::number((3).to_double())
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u078.grammar()
  let parsed = grammar.parse_default(
    "4",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(3, 1), (0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e \"4\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("4", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{\"v\":4},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "4")
  assert_eq(printed.to_string(), "4\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "token:4", "exit:e", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(6, "4", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion MultipleAlternativesWithCommonLabel_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    enter: (rule, frame) => {
      if rule == 1 && !frame.values.contains("v") {
        frame.values["v"] = Json::number(0.0)
      }
      frame
    },
    wrap: (rule, previous) => {
      let values : Map[String, Json] = Map([])
      if rule == 1 && !values.contains("v") {
        values["v"] = Json::number(0.0)
      }
      { values, shared: previous.shared.copy(), children: [previous], }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(
            bound_int(bound_rule(event, "e", -1).values, "v").to_string() + "\n",
          )
        1 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_rule(event, "e", 0).values, "v") *
            bound_int(bound_rule(event, "e", 1).values, "v")).to_double(),
          )
        2 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_rule(event, "e", 0).values, "v") +
            bound_int(bound_rule(event, "e", 1).values, "v")).to_double(),
          )
        3 =>
          event.frame.values["v"] = Json::number(
            bound_token_int(event, 6).to_double(),
          )
        4 =>
          event.frame.values["v"] = Json::number(
            bound_int(bound_rule(event, "e", -1).values, "v").to_double(),
          )
        5 => {
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") + 1).to_double(),
          )
          if event.context.tokens(7).is_empty() {
            raise @runtime.InvalidArgument("missing asserted token INC")
          }
        }
        6 => {
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") - 1).to_double(),
          )
          if event.context.tokens(8).is_empty() {
            raise @runtime.InvalidArgument("missing asserted token DEC")
          }
        }
        7 => event.frame.values["v"] = Json::number((3).to_double())
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u079.grammar()
  let parsed = grammar.parse_default(
    "1+2",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(3, 1), (3, 3), (2, 3), (0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e (e \"1\") \"+\" (e \"2\")))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("1+2", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{\"v\":3},\"children\":[{\"values\":{\"v\":1},\"children\":[]},{\"values\":{\"v\":2},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "1+2")
  assert_eq(printed.to_string(), "3\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:1", "exit:e", "token:+", "enter:e", "token:2",
    "exit:e", "exit:e", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "1", 0, 1, 1, 0, 0),
      (2, "+", 1, 2, 1, 1, 0),
      (6, "2", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion MultipleAlternativesWithCommonLabel_3" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    enter: (rule, frame) => {
      if rule == 1 && !frame.values.contains("v") {
        frame.values["v"] = Json::number(0.0)
      }
      frame
    },
    wrap: (rule, previous) => {
      let values : Map[String, Json] = Map([])
      if rule == 1 && !values.contains("v") {
        values["v"] = Json::number(0.0)
      }
      { values, shared: previous.shared.copy(), children: [previous], }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(
            bound_int(bound_rule(event, "e", -1).values, "v").to_string() + "\n",
          )
        1 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_rule(event, "e", 0).values, "v") *
            bound_int(bound_rule(event, "e", 1).values, "v")).to_double(),
          )
        2 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_rule(event, "e", 0).values, "v") +
            bound_int(bound_rule(event, "e", 1).values, "v")).to_double(),
          )
        3 =>
          event.frame.values["v"] = Json::number(
            bound_token_int(event, 6).to_double(),
          )
        4 =>
          event.frame.values["v"] = Json::number(
            bound_int(bound_rule(event, "e", -1).values, "v").to_double(),
          )
        5 => {
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") + 1).to_double(),
          )
          if event.context.tokens(7).is_empty() {
            raise @runtime.InvalidArgument("missing asserted token INC")
          }
        }
        6 => {
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") - 1).to_double(),
          )
          if event.context.tokens(8).is_empty() {
            raise @runtime.InvalidArgument("missing asserted token DEC")
          }
        }
        7 => event.frame.values["v"] = Json::number((3).to_double())
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u080.grammar()
  let parsed = grammar.parse_default(
    "1+2*3",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(3, 1), (3, 3), (3, 5), (1, 5), (2, 5), (0, 5)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"1\") \"+\" (e (e \"2\") \"*\" (e \"3\"))))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("1+2*3", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{\"v\":7},\"children\":[{\"values\":{\"v\":1},\"children\":[]},{\"values\":{\"v\":6},\"children\":[{\"values\":{\"v\":2},\"children\":[]},{\"values\":{\"v\":3},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "1+2*3")
  assert_eq(printed.to_string(), "7\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:1", "exit:e", "token:+", "enter:e", "enter:e",
    "token:2", "exit:e", "token:*", "enter:e", "token:3", "exit:e", "exit:e", "exit:e",
    "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "1", 0, 1, 1, 0, 0),
      (2, "+", 1, 2, 1, 1, 0),
      (6, "2", 2, 3, 1, 2, 0),
      (1, "*", 3, 4, 1, 3, 0),
      (6, "3", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion MultipleAlternativesWithCommonLabel_4" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    enter: (rule, frame) => {
      if rule == 1 && !frame.values.contains("v") {
        frame.values["v"] = Json::number(0.0)
      }
      frame
    },
    wrap: (rule, previous) => {
      let values : Map[String, Json] = Map([])
      if rule == 1 && !values.contains("v") {
        values["v"] = Json::number(0.0)
      }
      { values, shared: previous.shared.copy(), children: [previous], }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(
            bound_int(bound_rule(event, "e", -1).values, "v").to_string() + "\n",
          )
        1 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_rule(event, "e", 0).values, "v") *
            bound_int(bound_rule(event, "e", 1).values, "v")).to_double(),
          )
        2 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_rule(event, "e", 0).values, "v") +
            bound_int(bound_rule(event, "e", 1).values, "v")).to_double(),
          )
        3 =>
          event.frame.values["v"] = Json::number(
            bound_token_int(event, 6).to_double(),
          )
        4 =>
          event.frame.values["v"] = Json::number(
            bound_int(bound_rule(event, "e", -1).values, "v").to_double(),
          )
        5 => {
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") + 1).to_double(),
          )
          if event.context.tokens(7).is_empty() {
            raise @runtime.InvalidArgument("missing asserted token INC")
          }
        }
        6 => {
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") - 1).to_double(),
          )
          if event.context.tokens(8).is_empty() {
            raise @runtime.InvalidArgument("missing asserted token DEC")
          }
        }
        7 => event.frame.values["v"] = Json::number((3).to_double())
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u081.grammar()
  let parsed = grammar.parse_default(
    "i++*3",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(7, 1), (5, 3), (3, 5), (1, 5), (0, 5)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e (e \"i\") \"++\") \"*\" (e \"3\")))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("i++*3", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{\"v\":12},\"children\":[{\"values\":{\"v\":4},\"children\":[{\"values\":{\"v\":3},\"children\":[]}]},{\"values\":{\"v\":3},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "i++*3")
  assert_eq(printed.to_string(), "12\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "enter:e", "token:i", "exit:e", "token:++",
    "exit:e", "token:*", "enter:e", "token:3", "exit:e", "exit:e", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (5, "i", 0, 1, 1, 0, 0),
      (7, "++", 1, 3, 1, 1, 0),
      (1, "*", 3, 4, 1, 3, 0),
      (6, "3", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion MultipleAlternativesWithCommonLabel_5" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    enter: (rule, frame) => {
      if rule == 1 && !frame.values.contains("v") {
        frame.values["v"] = Json::number(0.0)
      }
      frame
    },
    wrap: (rule, previous) => {
      let values : Map[String, Json] = Map([])
      if rule == 1 && !values.contains("v") {
        values["v"] = Json::number(0.0)
      }
      { values, shared: previous.shared.copy(), children: [previous], }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(
            bound_int(bound_rule(event, "e", -1).values, "v").to_string() + "\n",
          )
        1 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_rule(event, "e", 0).values, "v") *
            bound_int(bound_rule(event, "e", 1).values, "v")).to_double(),
          )
        2 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_rule(event, "e", 0).values, "v") +
            bound_int(bound_rule(event, "e", 1).values, "v")).to_double(),
          )
        3 =>
          event.frame.values["v"] = Json::number(
            bound_token_int(event, 6).to_double(),
          )
        4 =>
          event.frame.values["v"] = Json::number(
            bound_int(bound_rule(event, "e", -1).values, "v").to_double(),
          )
        5 => {
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") + 1).to_double(),
          )
          if event.context.tokens(7).is_empty() {
            raise @runtime.InvalidArgument("missing asserted token INC")
          }
        }
        6 => {
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") - 1).to_double(),
          )
          if event.context.tokens(8).is_empty() {
            raise @runtime.InvalidArgument("missing asserted token DEC")
          }
        }
        7 => event.frame.values["v"] = Json::number((3).to_double())
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u082.grammar()
  let parsed = grammar.parse_default(
    "(99)+3",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(3, 3), (4, 4), (3, 6), (2, 6), (0, 6)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"(\" (e \"99\") \")\") \"+\" (e \"3\")))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("(99)+3", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{\"v\":102},\"children\":[{\"values\":{\"v\":99},\"children\":[{\"values\":{\"v\":99},\"children\":[]}]},{\"values\":{\"v\":3},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "(99)+3")
  assert_eq(printed.to_string(), "102\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:(", "enter:e", "token:99", "exit:e",
    "token:)", "exit:e", "token:+", "enter:e", "token:3", "exit:e", "exit:e", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "(", 0, 1, 1, 0, 0),
      (6, "99", 1, 3, 1, 1, 0),
      (4, ")", 3, 4, 1, 3, 0),
      (2, "+", 4, 5, 1, 4, 0),
      (6, "3", 5, 6, 1, 5, 0),
      (-1, "<EOF>", 6, 6, 1, 6, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion PrecedenceFilterConsidersContext" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        1 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u083.grammar()
  let parsed = grammar.parse_default(
    "aa",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 2), (1, 2)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(prog (statement (letterA \"a\")) (statement (letterA \"a\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("aa", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "aa<EOF>")
  assert_eq(
    printed.to_string(),
    "(prog (statement (letterA a)) (statement (letterA a)) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:prog", "enter:statement", "enter:letterA", "token:a", "exit:letterA",
    "exit:statement", "enter:statement", "enter:letterA", "token:a", "exit:letterA",
    "exit:statement", "token:<EOF>", "exit:prog",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "a", 0, 1, 1, 0, 0),
      (2, "a", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion PrefixAndOtherAlt_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u084.grammar()
  let parsed = grammar.parse_default(
    "-1",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 2)])
  assert_eq(parsed.tree.to_sexpr(), "(s (expr (literal \"-\" \"1\")) <EOF>)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("-1", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "-1<EOF>")
  assert_eq(printed.to_string(), "(s (expr (literal - 1)) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:expr", "enter:literal", "token:-", "token:1", "exit:literal",
    "exit:expr", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "-", 0, 1, 1, 0, 0),
      (3, "1", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion PrefixAndOtherAlt_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u085.grammar()
  let parsed = grammar.parse_default(
    "-1 + -1",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 7)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (expr (expr (literal \"-\" \"1\")) (op \"+\") (expr (literal \"-\" \"1\"))) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("-1 + -1", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "-1+-1<EOF>")
  assert_eq(
    printed.to_string(),
    "(s (expr (expr (literal - 1)) (op +) (expr (literal - 1))) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:expr", "enter:expr", "enter:literal", "token:-", "token:1",
    "exit:literal", "exit:expr", "enter:op", "token:+", "exit:op", "enter:expr",
    "enter:literal", "token:-", "token:1", "exit:literal", "exit:expr", "exit:expr",
    "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "-", 0, 1, 1, 0, 0),
      (3, "1", 1, 2, 1, 1, 0),
      (2, "+", 3, 4, 1, 3, 0),
      (1, "-", 5, 6, 1, 5, 0),
      (3, "1", 6, 7, 1, 6, 0),
      (-1, "<EOF>", 7, 7, 1, 7, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion PrefixOpWithActionAndLabel_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    enter: (rule, frame) => {
      if rule == 1 && !frame.values.contains("result") {
        frame.values["result"] = Json::null()
      }
      frame
    },
    wrap: (rule, previous) => {
      let values : Map[String, Json] = Map([])
      if rule == 1 && !values.contains("result") {
        values["result"] = Json::null()
      }
      { values, shared: previous.shared.copy(), children: [previous], }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(
            bound_text(bound_rule(event, "e", -1).values, "result") + "\n",
          )
        1 =>
          event.frame.values["result"] = Json::string(
            "(" +
            bound_token_text(event, 3) +
            "=" +
            bound_text(bound_label(event, [-1, 10]).values, "result") +
            ")",
          )
        2 =>
          event.frame.values["result"] = Json::string(
            bound_token_text(event, 3),
          )
        3 =>
          event.frame.values["result"] = Json::string(
            "(" +
            bound_text(bound_label(event, [-1, 10]).values, "result") +
            "+" +
            bound_text(bound_label(event, [19]).values, "result") +
            ")",
          )
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u086.grammar()
  let parsed = grammar.parse_default(
    "a",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(2, 1), (0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e \"a\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{\"result\":\"a\"},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a")
  assert_eq(printed.to_string(), "a\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "token:a", "exit:e", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(3, "a", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion PrefixOpWithActionAndLabel_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    enter: (rule, frame) => {
      if rule == 1 && !frame.values.contains("result") {
        frame.values["result"] = Json::null()
      }
      frame
    },
    wrap: (rule, previous) => {
      let values : Map[String, Json] = Map([])
      if rule == 1 && !values.contains("result") {
        values["result"] = Json::null()
      }
      { values, shared: previous.shared.copy(), children: [previous], }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(
            bound_text(bound_rule(event, "e", -1).values, "result") + "\n",
          )
        1 =>
          event.frame.values["result"] = Json::string(
            "(" +
            bound_token_text(event, 3) +
            "=" +
            bound_text(bound_label(event, [-1, 10]).values, "result") +
            ")",
          )
        2 =>
          event.frame.values["result"] = Json::string(
            bound_token_text(event, 3),
          )
        3 =>
          event.frame.values["result"] = Json::string(
            "(" +
            bound_text(bound_label(event, [-1, 10]).values, "result") +
            "+" +
            bound_text(bound_label(event, [19]).values, "result") +
            ")",
          )
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u087.grammar()
  let parsed = grammar.parse_default(
    "a+b",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(2, 1), (2, 3), (3, 3), (0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e (e \"a\") \"+\" (e \"b\")))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a+b", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{\"result\":\"(a+b)\"},\"children\":[{\"values\":{\"result\":\"a\"},\"children\":[]},{\"values\":{\"result\":\"b\"},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a+b")
  assert_eq(printed.to_string(), "(a+b)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "exit:e", "token:+", "enter:e", "token:b",
    "exit:e", "exit:e", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "a", 0, 1, 1, 0, 0),
      (2, "+", 1, 2, 1, 1, 0),
      (3, "b", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion PrefixOpWithActionAndLabel_3" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    enter: (rule, frame) => {
      if rule == 1 && !frame.values.contains("result") {
        frame.values["result"] = Json::null()
      }
      frame
    },
    wrap: (rule, previous) => {
      let values : Map[String, Json] = Map([])
      if rule == 1 && !values.contains("result") {
        values["result"] = Json::null()
      }
      { values, shared: previous.shared.copy(), children: [previous], }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(
            bound_text(bound_rule(event, "e", -1).values, "result") + "\n",
          )
        1 =>
          event.frame.values["result"] = Json::string(
            "(" +
            bound_token_text(event, 3) +
            "=" +
            bound_text(bound_label(event, [-1, 10]).values, "result") +
            ")",
          )
        2 =>
          event.frame.values["result"] = Json::string(
            bound_token_text(event, 3),
          )
        3 =>
          event.frame.values["result"] = Json::string(
            "(" +
            bound_text(bound_label(event, [-1, 10]).values, "result") +
            "+" +
            bound_text(bound_label(event, [19]).values, "result") +
            ")",
          )
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u088.grammar()
  let parsed = grammar.parse_default(
    "a=b+c",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(2, 3), (1, 3), (2, 5), (3, 5), (0, 5)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"a\" \"=\" (e \"b\")) \"+\" (e \"c\")))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a=b+c", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{\"result\":\"((a=b)+c)\"},\"children\":[{\"values\":{\"result\":\"(a=b)\"},\"children\":[{\"values\":{\"result\":\"b\"},\"children\":[]}]},{\"values\":{\"result\":\"c\"},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a=b+c")
  assert_eq(printed.to_string(), "((a=b)+c)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "token:=", "enter:e", "token:b",
    "exit:e", "exit:e", "token:+", "enter:e", "token:c", "exit:e", "exit:e", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "a", 0, 1, 1, 0, 0),
      (1, "=", 1, 2, 1, 1, 0),
      (3, "b", 2, 3, 1, 2, 0),
      (2, "+", 3, 4, 1, 3, 0),
      (3, "c", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion ReturnValueAndActions_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    enter: (rule, frame) => {
      if rule == 1 && !frame.values.contains("v") {
        frame.values["v"] = Json::number(0.0)
      }
      if rule == 1 && !frame.values.contains("ignored") {
        frame.values["ignored"] = Json::null()
      }
      frame
    },
    wrap: (rule, previous) => {
      let values : Map[String, Json] = Map([])
      if rule == 1 && !values.contains("v") {
        values["v"] = Json::number(0.0)
      }
      if rule == 1 && !values.contains("ignored") {
        values["ignored"] = Json::null()
      }
      { values, shared: previous.shared.copy(), children: [previous], }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(
            bound_int(bound_rule(event, "e", -1).values, "v").to_string() + "\n",
          )
        1 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") *
            bound_int(bound_label(event, [19, 24]).values, "v")).to_double(),
          )
        2 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") +
            bound_int(bound_label(event, [19, 24]).values, "v")).to_double(),
          )
        3 =>
          event.frame.values["v"] = Json::number(
            bound_token_int(event, 5).to_double(),
          )
        4 =>
          event.frame.values["v"] = Json::number(
            bound_int(bound_label(event, [11]).values, "v").to_double(),
          )
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u089.grammar()
  let parsed = grammar.parse_default(
    "4",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(3, 1), (0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e \"4\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("4", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{\"ignored\":null,\"v\":4},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "4")
  assert_eq(printed.to_string(), "4\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "token:4", "exit:e", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(5, "4", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion ReturnValueAndActions_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    enter: (rule, frame) => {
      if rule == 1 && !frame.values.contains("v") {
        frame.values["v"] = Json::number(0.0)
      }
      if rule == 1 && !frame.values.contains("ignored") {
        frame.values["ignored"] = Json::null()
      }
      frame
    },
    wrap: (rule, previous) => {
      let values : Map[String, Json] = Map([])
      if rule == 1 && !values.contains("v") {
        values["v"] = Json::number(0.0)
      }
      if rule == 1 && !values.contains("ignored") {
        values["ignored"] = Json::null()
      }
      { values, shared: previous.shared.copy(), children: [previous], }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(
            bound_int(bound_rule(event, "e", -1).values, "v").to_string() + "\n",
          )
        1 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") *
            bound_int(bound_label(event, [19, 24]).values, "v")).to_double(),
          )
        2 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") +
            bound_int(bound_label(event, [19, 24]).values, "v")).to_double(),
          )
        3 =>
          event.frame.values["v"] = Json::number(
            bound_token_int(event, 5).to_double(),
          )
        4 =>
          event.frame.values["v"] = Json::number(
            bound_int(bound_label(event, [11]).values, "v").to_double(),
          )
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u090.grammar()
  let parsed = grammar.parse_default(
    "1+2",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(3, 1), (3, 3), (2, 3), (0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e (e \"1\") \"+\" (e \"2\")))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("1+2", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{\"ignored\":null,\"v\":3},\"children\":[{\"values\":{\"ignored\":null,\"v\":1},\"children\":[]},{\"values\":{\"ignored\":null,\"v\":2},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "1+2")
  assert_eq(printed.to_string(), "3\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:1", "exit:e", "token:+", "enter:e", "token:2",
    "exit:e", "exit:e", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (5, "1", 0, 1, 1, 0, 0),
      (2, "+", 1, 2, 1, 1, 0),
      (5, "2", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion ReturnValueAndActions_3" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    enter: (rule, frame) => {
      if rule == 1 && !frame.values.contains("v") {
        frame.values["v"] = Json::number(0.0)
      }
      if rule == 1 && !frame.values.contains("ignored") {
        frame.values["ignored"] = Json::null()
      }
      frame
    },
    wrap: (rule, previous) => {
      let values : Map[String, Json] = Map([])
      if rule == 1 && !values.contains("v") {
        values["v"] = Json::number(0.0)
      }
      if rule == 1 && !values.contains("ignored") {
        values["ignored"] = Json::null()
      }
      { values, shared: previous.shared.copy(), children: [previous], }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(
            bound_int(bound_rule(event, "e", -1).values, "v").to_string() + "\n",
          )
        1 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") *
            bound_int(bound_label(event, [19, 24]).values, "v")).to_double(),
          )
        2 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") +
            bound_int(bound_label(event, [19, 24]).values, "v")).to_double(),
          )
        3 =>
          event.frame.values["v"] = Json::number(
            bound_token_int(event, 5).to_double(),
          )
        4 =>
          event.frame.values["v"] = Json::number(
            bound_int(bound_label(event, [11]).values, "v").to_double(),
          )
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u091.grammar()
  let parsed = grammar.parse_default(
    "1+2*3",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(3, 1), (3, 3), (3, 5), (1, 5), (2, 5), (0, 5)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"1\") \"+\" (e (e \"2\") \"*\" (e \"3\"))))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("1+2*3", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{\"ignored\":null,\"v\":7},\"children\":[{\"values\":{\"ignored\":null,\"v\":1},\"children\":[]},{\"values\":{\"ignored\":null,\"v\":6},\"children\":[{\"values\":{\"ignored\":null,\"v\":2},\"children\":[]},{\"values\":{\"ignored\":null,\"v\":3},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "1+2*3")
  assert_eq(printed.to_string(), "7\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:1", "exit:e", "token:+", "enter:e", "enter:e",
    "token:2", "exit:e", "token:*", "enter:e", "token:3", "exit:e", "exit:e", "exit:e",
    "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (5, "1", 0, 1, 1, 0, 0),
      (2, "+", 1, 2, 1, 1, 0),
      (5, "2", 2, 3, 1, 2, 0),
      (1, "*", 3, 4, 1, 3, 0),
      (5, "3", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion ReturnValueAndActions_4" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    enter: (rule, frame) => {
      if rule == 1 && !frame.values.contains("v") {
        frame.values["v"] = Json::number(0.0)
      }
      if rule == 1 && !frame.values.contains("ignored") {
        frame.values["ignored"] = Json::null()
      }
      frame
    },
    wrap: (rule, previous) => {
      let values : Map[String, Json] = Map([])
      if rule == 1 && !values.contains("v") {
        values["v"] = Json::number(0.0)
      }
      if rule == 1 && !values.contains("ignored") {
        values["ignored"] = Json::null()
      }
      { values, shared: previous.shared.copy(), children: [previous], }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(
            bound_int(bound_rule(event, "e", -1).values, "v").to_string() + "\n",
          )
        1 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") *
            bound_int(bound_label(event, [19, 24]).values, "v")).to_double(),
          )
        2 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") +
            bound_int(bound_label(event, [19, 24]).values, "v")).to_double(),
          )
        3 =>
          event.frame.values["v"] = Json::number(
            bound_token_int(event, 5).to_double(),
          )
        4 =>
          event.frame.values["v"] = Json::number(
            bound_int(bound_label(event, [11]).values, "v").to_double(),
          )
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u092.grammar()
  let parsed = grammar.parse_default(
    "(1+2)*3",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [
    (3, 2),
    (3, 4),
    (2, 4),
    (4, 5),
    (3, 7),
    (1, 7),
    (0, 7),
  ])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"(\" (e (e \"1\") \"+\" (e \"2\")) \")\") \"*\" (e \"3\")))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("(1+2)*3", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{\"ignored\":null,\"v\":9},\"children\":[{\"values\":{\"ignored\":null,\"v\":3},\"children\":[{\"values\":{\"ignored\":null,\"v\":3},\"children\":[{\"values\":{\"ignored\":null,\"v\":1},\"children\":[]},{\"values\":{\"ignored\":null,\"v\":2},\"children\":[]}]}]},{\"values\":{\"ignored\":null,\"v\":3},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "(1+2)*3")
  assert_eq(printed.to_string(), "9\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:(", "enter:e", "enter:e", "token:1",
    "exit:e", "token:+", "enter:e", "token:2", "exit:e", "exit:e", "token:)", "exit:e",
    "token:*", "enter:e", "token:3", "exit:e", "exit:e", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "(", 0, 1, 1, 0, 0),
      (5, "1", 1, 2, 1, 1, 0),
      (2, "+", 2, 3, 1, 2, 0),
      (5, "2", 3, 4, 1, 3, 0),
      (4, ")", 4, 5, 1, 4, 0),
      (1, "*", 5, 6, 1, 5, 0),
      (5, "3", 6, 7, 1, 6, 0),
      (-1, "<EOF>", 7, 7, 1, 7, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion ReturnValueAndActionsAndLabels_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    enter: (rule, frame) => {
      if rule == 1 && !frame.values.contains("v") {
        frame.values["v"] = Json::number(0.0)
      }
      frame
    },
    wrap: (rule, previous) => {
      let values : Map[String, Json] = Map([])
      if rule == 1 && !values.contains("v") {
        values["v"] = Json::number(0.0)
      }
      { values, shared: previous.shared.copy(), children: [previous], }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(
            bound_int(bound_rule(event, "e", -1).values, "v").to_string() + "\n",
          )
        1 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") *
            bound_int(bound_label(event, [21, 26]).values, "v")).to_double(),
          )
        2 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") +
            bound_int(bound_label(event, [21, 26]).values, "v")).to_double(),
          )
        3 =>
          event.frame.values["v"] = Json::number(
            bound_token_int(event, 8).to_double(),
          )
        4 =>
          event.frame.values["v"] = Json::number(
            bound_int(bound_label(event, [-1, 11]).values, "v").to_double(),
          )
        5 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1, 11]).values, "v") + 1).to_double(),
          )
        6 => event.frame.values["v"] = Json::number((3).to_double())
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u093.grammar()
  let parsed = grammar.parse_default(
    "4",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(3, 1), (0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e \"4\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("4", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{\"v\":4},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "4")
  assert_eq(printed.to_string(), "4\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "token:4", "exit:e", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(8, "4", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion ReturnValueAndActionsAndLabels_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    enter: (rule, frame) => {
      if rule == 1 && !frame.values.contains("v") {
        frame.values["v"] = Json::number(0.0)
      }
      frame
    },
    wrap: (rule, previous) => {
      let values : Map[String, Json] = Map([])
      if rule == 1 && !values.contains("v") {
        values["v"] = Json::number(0.0)
      }
      { values, shared: previous.shared.copy(), children: [previous], }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(
            bound_int(bound_rule(event, "e", -1).values, "v").to_string() + "\n",
          )
        1 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") *
            bound_int(bound_label(event, [21, 26]).values, "v")).to_double(),
          )
        2 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") +
            bound_int(bound_label(event, [21, 26]).values, "v")).to_double(),
          )
        3 =>
          event.frame.values["v"] = Json::number(
            bound_token_int(event, 8).to_double(),
          )
        4 =>
          event.frame.values["v"] = Json::number(
            bound_int(bound_label(event, [-1, 11]).values, "v").to_double(),
          )
        5 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1, 11]).values, "v") + 1).to_double(),
          )
        6 => event.frame.values["v"] = Json::number((3).to_double())
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u094.grammar()
  let parsed = grammar.parse_default(
    "1+2",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(3, 1), (3, 3), (2, 3), (0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e (e \"1\") \"+\" (e \"2\")))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("1+2", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{\"v\":3},\"children\":[{\"values\":{\"v\":1},\"children\":[]},{\"values\":{\"v\":2},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "1+2")
  assert_eq(printed.to_string(), "3\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:1", "exit:e", "token:+", "enter:e", "token:2",
    "exit:e", "exit:e", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (8, "1", 0, 1, 1, 0, 0),
      (2, "+", 1, 2, 1, 1, 0),
      (8, "2", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion ReturnValueAndActionsAndLabels_3" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    enter: (rule, frame) => {
      if rule == 1 && !frame.values.contains("v") {
        frame.values["v"] = Json::number(0.0)
      }
      frame
    },
    wrap: (rule, previous) => {
      let values : Map[String, Json] = Map([])
      if rule == 1 && !values.contains("v") {
        values["v"] = Json::number(0.0)
      }
      { values, shared: previous.shared.copy(), children: [previous], }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(
            bound_int(bound_rule(event, "e", -1).values, "v").to_string() + "\n",
          )
        1 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") *
            bound_int(bound_label(event, [21, 26]).values, "v")).to_double(),
          )
        2 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") +
            bound_int(bound_label(event, [21, 26]).values, "v")).to_double(),
          )
        3 =>
          event.frame.values["v"] = Json::number(
            bound_token_int(event, 8).to_double(),
          )
        4 =>
          event.frame.values["v"] = Json::number(
            bound_int(bound_label(event, [-1, 11]).values, "v").to_double(),
          )
        5 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1, 11]).values, "v") + 1).to_double(),
          )
        6 => event.frame.values["v"] = Json::number((3).to_double())
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u095.grammar()
  let parsed = grammar.parse_default(
    "1+2*3",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(3, 1), (3, 3), (3, 5), (1, 5), (2, 5), (0, 5)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"1\") \"+\" (e (e \"2\") \"*\" (e \"3\"))))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("1+2*3", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{\"v\":7},\"children\":[{\"values\":{\"v\":1},\"children\":[]},{\"values\":{\"v\":6},\"children\":[{\"values\":{\"v\":2},\"children\":[]},{\"values\":{\"v\":3},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "1+2*3")
  assert_eq(printed.to_string(), "7\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:1", "exit:e", "token:+", "enter:e", "enter:e",
    "token:2", "exit:e", "token:*", "enter:e", "token:3", "exit:e", "exit:e", "exit:e",
    "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (8, "1", 0, 1, 1, 0, 0),
      (2, "+", 1, 2, 1, 1, 0),
      (8, "2", 2, 3, 1, 2, 0),
      (1, "*", 3, 4, 1, 3, 0),
      (8, "3", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion ReturnValueAndActionsAndLabels_4" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    enter: (rule, frame) => {
      if rule == 1 && !frame.values.contains("v") {
        frame.values["v"] = Json::number(0.0)
      }
      frame
    },
    wrap: (rule, previous) => {
      let values : Map[String, Json] = Map([])
      if rule == 1 && !values.contains("v") {
        values["v"] = Json::number(0.0)
      }
      { values, shared: previous.shared.copy(), children: [previous], }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(
            bound_int(bound_rule(event, "e", -1).values, "v").to_string() + "\n",
          )
        1 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") *
            bound_int(bound_label(event, [21, 26]).values, "v")).to_double(),
          )
        2 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1]).values, "v") +
            bound_int(bound_label(event, [21, 26]).values, "v")).to_double(),
          )
        3 =>
          event.frame.values["v"] = Json::number(
            bound_token_int(event, 8).to_double(),
          )
        4 =>
          event.frame.values["v"] = Json::number(
            bound_int(bound_label(event, [-1, 11]).values, "v").to_double(),
          )
        5 =>
          event.frame.values["v"] = Json::number(
            (bound_int(bound_label(event, [-1, 11]).values, "v") + 1).to_double(),
          )
        6 => event.frame.values["v"] = Json::number((3).to_double())
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u096.grammar()
  let parsed = grammar.parse_default(
    "i++*3",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(6, 1), (5, 3), (3, 5), (1, 5), (0, 5)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e (e \"i\") \"++\") \"*\" (e \"3\")))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("i++*3", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{\"v\":12},\"children\":[{\"values\":{\"v\":4},\"children\":[{\"values\":{\"v\":3},\"children\":[]}]},{\"values\":{\"v\":3},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "i++*3")
  assert_eq(printed.to_string(), "12\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "enter:e", "token:i", "exit:e", "token:++",
    "exit:e", "token:*", "enter:e", "token:3", "exit:e", "exit:e", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (7, "i", 0, 1, 1, 0, 0),
      (5, "++", 1, 3, 1, 1, 0),
      (1, "*", 3, 4, 1, 3, 0),
      (8, "3", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion ReturnValueAndActionsList1_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u097.grammar()
  let parsed = grammar.parse_default(
    "a*b",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (expr (expr \"a\") \"*\" (expr \"b\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a*b", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a*b<EOF>")
  assert_eq(printed.to_string(), "(s (expr (expr a) * (expr b)) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:expr", "enter:expr", "token:a", "exit:expr", "token:*", "enter:expr",
    "token:b", "exit:expr", "exit:expr", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (4, "a", 0, 1, 1, 0, 0),
      (1, "*", 1, 2, 1, 1, 0),
      (4, "b", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion ReturnValueAndActionsList1_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u098.grammar()
  let parsed = grammar.parse_default(
    "a,c>>x",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 6)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (expr (expr \"a\") \",\" (expr \"c\") \">>\" (expr \"x\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a,c>>x", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a,c>>x<EOF>")
  assert_eq(
    printed.to_string(),
    "(s (expr (expr a) , (expr c) >> (expr x)) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:expr", "enter:expr", "token:a", "exit:expr", "token:,", "enter:expr",
    "token:c", "exit:expr", "token:>>", "enter:expr", "token:x", "exit:expr", "exit:expr",
    "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (4, "a", 0, 1, 1, 0, 0),
      (2, ",", 1, 2, 1, 1, 0),
      (4, "c", 2, 3, 1, 2, 0),
      (3, ">>", 3, 5, 1, 3, 0),
      (4, "x", 5, 6, 1, 5, 0),
      (-1, "<EOF>", 6, 6, 1, 6, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion ReturnValueAndActionsList1_3" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u099.grammar()
  let parsed = grammar.parse_default(
    "x",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (expr \"x\") <EOF>)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "x<EOF>")
  assert_eq(printed.to_string(), "(s (expr x) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:expr", "token:x", "exit:expr", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(4, "x", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion ReturnValueAndActionsList1_4" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u100.grammar()
  let parsed = grammar.parse_default(
    "a*b,c,x*y>>r",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 12)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (expr (expr (expr \"a\") \"*\" (expr \"b\")) \",\" (expr \"c\") \",\" (expr (expr \"x\") \"*\" (expr \"y\")) \">>\" (expr \"r\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a*b,c,x*y>>r", lexer_action=(_, _) => {
    ()
  })
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a*b,c,x*y>>r<EOF>")
  assert_eq(
    printed.to_string(),
    "(s (expr (expr (expr a) * (expr b)) , (expr c) , (expr (expr x) * (expr y)) >> (expr r)) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:expr", "enter:expr", "enter:expr", "token:a", "exit:expr",
    "token:*", "enter:expr", "token:b", "exit:expr", "exit:expr", "token:,", "enter:expr",
    "token:c", "exit:expr", "token:,", "enter:expr", "enter:expr", "token:x", "exit:expr",
    "token:*", "enter:expr", "token:y", "exit:expr", "exit:expr", "token:>>", "enter:expr",
    "token:r", "exit:expr", "exit:expr", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (4, "a", 0, 1, 1, 0, 0),
      (1, "*", 1, 2, 1, 1, 0),
      (4, "b", 2, 3, 1, 2, 0),
      (2, ",", 3, 4, 1, 3, 0),
      (4, "c", 4, 5, 1, 4, 0),
      (2, ",", 5, 6, 1, 5, 0),
      (4, "x", 6, 7, 1, 6, 0),
      (1, "*", 7, 8, 1, 7, 0),
      (4, "y", 8, 9, 1, 8, 0),
      (3, ">>", 9, 11, 1, 9, 0),
      (4, "r", 11, 12, 1, 11, 0),
      (-1, "<EOF>", 12, 12, 1, 12, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion ReturnValueAndActionsList2_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u101.grammar()
  let parsed = grammar.parse_default(
    "a*b",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (expr (expr \"a\") \"*\" (expr \"b\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a*b", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a*b<EOF>")
  assert_eq(printed.to_string(), "(s (expr (expr a) * (expr b)) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:expr", "enter:expr", "token:a", "exit:expr", "token:*", "enter:expr",
    "token:b", "exit:expr", "exit:expr", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (4, "a", 0, 1, 1, 0, 0),
      (1, "*", 1, 2, 1, 1, 0),
      (4, "b", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion ReturnValueAndActionsList2_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u102.grammar()
  let parsed = grammar.parse_default(
    "a,c>>x",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 6)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (expr (expr (expr \"a\") \",\" (expr \"c\")) \">>\" (expr \"x\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a,c>>x", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a,c>>x<EOF>")
  assert_eq(
    printed.to_string(),
    "(s (expr (expr (expr a) , (expr c)) >> (expr x)) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:expr", "enter:expr", "enter:expr", "token:a", "exit:expr",
    "token:,", "enter:expr", "token:c", "exit:expr", "exit:expr", "token:>>", "enter:expr",
    "token:x", "exit:expr", "exit:expr", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (4, "a", 0, 1, 1, 0, 0),
      (2, ",", 1, 2, 1, 1, 0),
      (4, "c", 2, 3, 1, 2, 0),
      (3, ">>", 3, 5, 1, 3, 0),
      (4, "x", 5, 6, 1, 5, 0),
      (-1, "<EOF>", 6, 6, 1, 6, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion ReturnValueAndActionsList2_3" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u103.grammar()
  let parsed = grammar.parse_default(
    "x",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (expr \"x\") <EOF>)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "x<EOF>")
  assert_eq(printed.to_string(), "(s (expr x) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:expr", "token:x", "exit:expr", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(4, "x", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion ReturnValueAndActionsList2_4" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u104.grammar()
  let parsed = grammar.parse_default(
    "a*b,c,x*y>>r",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 12)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (expr (expr (expr (expr (expr \"a\") \"*\" (expr \"b\")) \",\" (expr \"c\")) \",\" (expr (expr \"x\") \"*\" (expr \"y\"))) \">>\" (expr \"r\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a*b,c,x*y>>r", lexer_action=(_, _) => {
    ()
  })
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a*b,c,x*y>>r<EOF>")
  assert_eq(
    printed.to_string(),
    "(s (expr (expr (expr (expr (expr a) * (expr b)) , (expr c)) , (expr (expr x) * (expr y))) >> (expr r)) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:expr", "enter:expr", "enter:expr", "enter:expr", "enter:expr",
    "token:a", "exit:expr", "token:*", "enter:expr", "token:b", "exit:expr", "exit:expr",
    "token:,", "enter:expr", "token:c", "exit:expr", "exit:expr", "token:,", "enter:expr",
    "enter:expr", "token:x", "exit:expr", "token:*", "enter:expr", "token:y", "exit:expr",
    "exit:expr", "exit:expr", "token:>>", "enter:expr", "token:r", "exit:expr", "exit:expr",
    "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (4, "a", 0, 1, 1, 0, 0),
      (1, "*", 1, 2, 1, 1, 0),
      (4, "b", 2, 3, 1, 2, 0),
      (2, ",", 3, 4, 1, 3, 0),
      (4, "c", 4, 5, 1, 4, 0),
      (2, ",", 5, 6, 1, 5, 0),
      (4, "x", 6, 7, 1, 6, 0),
      (1, "*", 7, 8, 1, 7, 0),
      (4, "y", 8, 9, 1, 8, 0),
      (3, ">>", 9, 11, 1, 9, 0),
      (4, "r", 11, 12, 1, 11, 0),
      (-1, "<EOF>", 12, 12, 1, 12, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion SemPred" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        1 => true
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u105.grammar()
  let parsed = grammar.parse_default(
    "x y z",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a (a (a \"x\") \"y\") \"z\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x y z", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "xyz")
  assert_eq(printed.to_string(), "(s (a (a (a x) y) z))\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "enter:a", "enter:a", "token:x", "exit:a", "token:y", "exit:a",
    "token:z", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "x", 0, 1, 1, 0, 0),
      (1, "y", 2, 3, 1, 2, 0),
      (1, "z", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion SemPredFailOption" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        1 => false
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u106.grammar()
  let parsed = grammar.parse_default(
    "x y z",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a (a \"x\") \"y\" (error \"z\")))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(4)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(1, "z", 4, 5, 1, 4, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x y z", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "xyz")
  assert_eq(printed.to_string(), "(s (a (a x) y z))\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "enter:a", "token:x", "exit:a", "token:y", "error:z", "exit:a",
    "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "x", 0, 1, 1, 0, 0),
      (1, "y", 2, 3, 1, 2, 0),
      (1, "z", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion Simple_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u107.grammar()
  let parsed = grammar.parse_default(
    "x",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"x\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "x")
  assert_eq(printed.to_string(), "(s (a x))\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:x", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "x", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion Simple_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u108.grammar()
  let parsed = grammar.parse_default(
    "x y",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a (a \"x\") \"y\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x y", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "xy")
  assert_eq(printed.to_string(), "(s (a (a x) y))\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "enter:a", "token:x", "exit:a", "token:y", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "x", 0, 1, 1, 0, 0),
      (1, "y", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion Simple_3" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u109.grammar()
  let parsed = grammar.parse_default(
    "x y z",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a (a (a \"x\") \"y\") \"z\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x y z", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "xyz")
  assert_eq(printed.to_string(), "(s (a (a (a x) y) z))\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "enter:a", "enter:a", "token:x", "exit:a", "token:y", "exit:a",
    "token:z", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "x", 0, 1, 1, 0, 0),
      (1, "y", 2, 3, 1, 2, 0),
      (1, "z", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion TernaryExpr_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u110.grammar()
  let parsed = grammar.parse_default(
    "a",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e \"a\") <EOF>)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a<EOF>")
  assert_eq(printed.to_string(), "(s (e a) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "token:a", "exit:e", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(6, "a", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion TernaryExpr_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u111.grammar()
  let parsed = grammar.parse_default(
    "a+b",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e (e \"a\") \"+\" (e \"b\")) <EOF>)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a+b", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a+b<EOF>")
  assert_eq(printed.to_string(), "(s (e (e a) + (e b)) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "exit:e", "token:+", "enter:e", "token:b",
    "exit:e", "exit:e", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "a", 0, 1, 1, 0, 0),
      (2, "+", 1, 2, 1, 1, 0),
      (6, "b", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion TernaryExpr_3" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u112.grammar()
  let parsed = grammar.parse_default(
    "a*b",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e (e \"a\") \"*\" (e \"b\")) <EOF>)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a*b", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a*b<EOF>")
  assert_eq(printed.to_string(), "(s (e (e a) * (e b)) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "exit:e", "token:*", "enter:e", "token:b",
    "exit:e", "exit:e", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "a", 0, 1, 1, 0, 0),
      (1, "*", 1, 2, 1, 1, 0),
      (6, "b", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion TernaryExpr_4" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u113.grammar()
  let parsed = grammar.parse_default(
    "a?b:c",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"a\") \"?\" (e \"b\") \":\" (e \"c\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a?b:c", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a?b:c<EOF>")
  assert_eq(printed.to_string(), "(s (e (e a) ? (e b) : (e c)) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "exit:e", "token:?", "enter:e", "token:b",
    "exit:e", "token::", "enter:e", "token:c", "exit:e", "exit:e", "token:<EOF>",
    "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "a", 0, 1, 1, 0, 0),
      (3, "?", 1, 2, 1, 1, 0),
      (6, "b", 2, 3, 1, 2, 0),
      (4, ":", 3, 4, 1, 3, 0),
      (6, "c", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion TernaryExpr_5" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u114.grammar()
  let parsed = grammar.parse_default(
    "a=b=c",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"a\") \"=\" (e (e \"b\") \"=\" (e \"c\"))) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a=b=c", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a=b=c<EOF>")
  assert_eq(printed.to_string(), "(s (e (e a) = (e (e b) = (e c))) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "exit:e", "token:=", "enter:e", "enter:e",
    "token:b", "exit:e", "token:=", "enter:e", "token:c", "exit:e", "exit:e", "exit:e",
    "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "a", 0, 1, 1, 0, 0),
      (5, "=", 1, 2, 1, 1, 0),
      (6, "b", 2, 3, 1, 2, 0),
      (5, "=", 3, 4, 1, 3, 0),
      (6, "c", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion TernaryExpr_6" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u115.grammar()
  let parsed = grammar.parse_default(
    "a?b+c:d",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 7)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"a\") \"?\" (e (e \"b\") \"+\" (e \"c\")) \":\" (e \"d\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a?b+c:d", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a?b+c:d<EOF>")
  assert_eq(
    printed.to_string(),
    "(s (e (e a) ? (e (e b) + (e c)) : (e d)) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "exit:e", "token:?", "enter:e", "enter:e",
    "token:b", "exit:e", "token:+", "enter:e", "token:c", "exit:e", "exit:e", "token::",
    "enter:e", "token:d", "exit:e", "exit:e", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "a", 0, 1, 1, 0, 0),
      (3, "?", 1, 2, 1, 1, 0),
      (6, "b", 2, 3, 1, 2, 0),
      (2, "+", 3, 4, 1, 3, 0),
      (6, "c", 4, 5, 1, 4, 0),
      (4, ":", 5, 6, 1, 5, 0),
      (6, "d", 6, 7, 1, 6, 0),
      (-1, "<EOF>", 7, 7, 1, 7, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion TernaryExpr_7" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u116.grammar()
  let parsed = grammar.parse_default(
    "a?b=c:d",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 7)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"a\") \"?\" (e (e \"b\") \"=\" (e \"c\")) \":\" (e \"d\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a?b=c:d", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a?b=c:d<EOF>")
  assert_eq(
    printed.to_string(),
    "(s (e (e a) ? (e (e b) = (e c)) : (e d)) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "exit:e", "token:?", "enter:e", "enter:e",
    "token:b", "exit:e", "token:=", "enter:e", "token:c", "exit:e", "exit:e", "token::",
    "enter:e", "token:d", "exit:e", "exit:e", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "a", 0, 1, 1, 0, 0),
      (3, "?", 1, 2, 1, 1, 0),
      (6, "b", 2, 3, 1, 2, 0),
      (5, "=", 3, 4, 1, 3, 0),
      (6, "c", 4, 5, 1, 4, 0),
      (4, ":", 5, 6, 1, 5, 0),
      (6, "d", 6, 7, 1, 6, 0),
      (-1, "<EOF>", 7, 7, 1, 7, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion TernaryExpr_8" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u117.grammar()
  let parsed = grammar.parse_default(
    "a? b?c:d : e",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 12)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"a\") \"?\" (e (e \"b\") \"?\" (e \"c\") \":\" (e \"d\")) \":\" (e \"e\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a? b?c:d : e", lexer_action=(_, _) => {
    ()
  })
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a?b?c:d:e<EOF>")
  assert_eq(
    printed.to_string(),
    "(s (e (e a) ? (e (e b) ? (e c) : (e d)) : (e e)) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "exit:e", "token:?", "enter:e", "enter:e",
    "token:b", "exit:e", "token:?", "enter:e", "token:c", "exit:e", "token::", "enter:e",
    "token:d", "exit:e", "exit:e", "token::", "enter:e", "token:e", "exit:e", "exit:e",
    "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "a", 0, 1, 1, 0, 0),
      (3, "?", 1, 2, 1, 1, 0),
      (6, "b", 3, 4, 1, 3, 0),
      (3, "?", 4, 5, 1, 4, 0),
      (6, "c", 5, 6, 1, 5, 0),
      (4, ":", 6, 7, 1, 6, 0),
      (6, "d", 7, 8, 1, 7, 0),
      (4, ":", 9, 10, 1, 9, 0),
      (6, "e", 11, 12, 1, 11, 0),
      (-1, "<EOF>", 12, 12, 1, 12, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion TernaryExpr_9" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u118.grammar()
  let parsed = grammar.parse_default(
    "a?b: c?d:e",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 10)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"a\") \"?\" (e \"b\") \":\" (e (e \"c\") \"?\" (e \"d\") \":\" (e \"e\"))) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a?b: c?d:e", lexer_action=(_, _) => {
    ()
  })
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a?b:c?d:e<EOF>")
  assert_eq(
    printed.to_string(),
    "(s (e (e a) ? (e b) : (e (e c) ? (e d) : (e e))) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "exit:e", "token:?", "enter:e", "token:b",
    "exit:e", "token::", "enter:e", "enter:e", "token:c", "exit:e", "token:?", "enter:e",
    "token:d", "exit:e", "token::", "enter:e", "token:e", "exit:e", "exit:e", "exit:e",
    "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "a", 0, 1, 1, 0, 0),
      (3, "?", 1, 2, 1, 1, 0),
      (6, "b", 2, 3, 1, 2, 0),
      (4, ":", 3, 4, 1, 3, 0),
      (6, "c", 5, 6, 1, 5, 0),
      (3, "?", 6, 7, 1, 6, 0),
      (6, "d", 7, 8, 1, 7, 0),
      (4, ":", 8, 9, 1, 8, 0),
      (6, "e", 9, 10, 1, 9, 0),
      (-1, "<EOF>", 10, 10, 1, 10, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion TernaryExprExplicitAssociativity_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u119.grammar()
  let parsed = grammar.parse_default(
    "a",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e \"a\") <EOF>)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a<EOF>")
  assert_eq(printed.to_string(), "(s (e a) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "token:a", "exit:e", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(6, "a", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion TernaryExprExplicitAssociativity_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u120.grammar()
  let parsed = grammar.parse_default(
    "a+b",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e (e \"a\") \"+\" (e \"b\")) <EOF>)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a+b", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a+b<EOF>")
  assert_eq(printed.to_string(), "(s (e (e a) + (e b)) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "exit:e", "token:+", "enter:e", "token:b",
    "exit:e", "exit:e", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "a", 0, 1, 1, 0, 0),
      (2, "+", 1, 2, 1, 1, 0),
      (6, "b", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion TernaryExprExplicitAssociativity_3" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u121.grammar()
  let parsed = grammar.parse_default(
    "a*b",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e (e \"a\") \"*\" (e \"b\")) <EOF>)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a*b", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a*b<EOF>")
  assert_eq(printed.to_string(), "(s (e (e a) * (e b)) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "exit:e", "token:*", "enter:e", "token:b",
    "exit:e", "exit:e", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "a", 0, 1, 1, 0, 0),
      (1, "*", 1, 2, 1, 1, 0),
      (6, "b", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion TernaryExprExplicitAssociativity_4" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u122.grammar()
  let parsed = grammar.parse_default(
    "a?b:c",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"a\") \"?\" (e \"b\") \":\" (e \"c\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a?b:c", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a?b:c<EOF>")
  assert_eq(printed.to_string(), "(s (e (e a) ? (e b) : (e c)) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "exit:e", "token:?", "enter:e", "token:b",
    "exit:e", "token::", "enter:e", "token:c", "exit:e", "exit:e", "token:<EOF>",
    "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "a", 0, 1, 1, 0, 0),
      (3, "?", 1, 2, 1, 1, 0),
      (6, "b", 2, 3, 1, 2, 0),
      (4, ":", 3, 4, 1, 3, 0),
      (6, "c", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion TernaryExprExplicitAssociativity_5" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u123.grammar()
  let parsed = grammar.parse_default(
    "a=b=c",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"a\") \"=\" (e (e \"b\") \"=\" (e \"c\"))) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a=b=c", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a=b=c<EOF>")
  assert_eq(printed.to_string(), "(s (e (e a) = (e (e b) = (e c))) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "exit:e", "token:=", "enter:e", "enter:e",
    "token:b", "exit:e", "token:=", "enter:e", "token:c", "exit:e", "exit:e", "exit:e",
    "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "a", 0, 1, 1, 0, 0),
      (5, "=", 1, 2, 1, 1, 0),
      (6, "b", 2, 3, 1, 2, 0),
      (5, "=", 3, 4, 1, 3, 0),
      (6, "c", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion TernaryExprExplicitAssociativity_6" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u124.grammar()
  let parsed = grammar.parse_default(
    "a?b+c:d",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 7)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"a\") \"?\" (e (e \"b\") \"+\" (e \"c\")) \":\" (e \"d\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a?b+c:d", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a?b+c:d<EOF>")
  assert_eq(
    printed.to_string(),
    "(s (e (e a) ? (e (e b) + (e c)) : (e d)) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "exit:e", "token:?", "enter:e", "enter:e",
    "token:b", "exit:e", "token:+", "enter:e", "token:c", "exit:e", "exit:e", "token::",
    "enter:e", "token:d", "exit:e", "exit:e", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "a", 0, 1, 1, 0, 0),
      (3, "?", 1, 2, 1, 1, 0),
      (6, "b", 2, 3, 1, 2, 0),
      (2, "+", 3, 4, 1, 3, 0),
      (6, "c", 4, 5, 1, 4, 0),
      (4, ":", 5, 6, 1, 5, 0),
      (6, "d", 6, 7, 1, 6, 0),
      (-1, "<EOF>", 7, 7, 1, 7, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion TernaryExprExplicitAssociativity_7" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u125.grammar()
  let parsed = grammar.parse_default(
    "a?b=c:d",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 7)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"a\") \"?\" (e (e \"b\") \"=\" (e \"c\")) \":\" (e \"d\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a?b=c:d", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a?b=c:d<EOF>")
  assert_eq(
    printed.to_string(),
    "(s (e (e a) ? (e (e b) = (e c)) : (e d)) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "exit:e", "token:?", "enter:e", "enter:e",
    "token:b", "exit:e", "token:=", "enter:e", "token:c", "exit:e", "exit:e", "token::",
    "enter:e", "token:d", "exit:e", "exit:e", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "a", 0, 1, 1, 0, 0),
      (3, "?", 1, 2, 1, 1, 0),
      (6, "b", 2, 3, 1, 2, 0),
      (5, "=", 3, 4, 1, 3, 0),
      (6, "c", 4, 5, 1, 4, 0),
      (4, ":", 5, 6, 1, 5, 0),
      (6, "d", 6, 7, 1, 6, 0),
      (-1, "<EOF>", 7, 7, 1, 7, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion TernaryExprExplicitAssociativity_8" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u126.grammar()
  let parsed = grammar.parse_default(
    "a? b?c:d : e",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 12)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"a\") \"?\" (e (e \"b\") \"?\" (e \"c\") \":\" (e \"d\")) \":\" (e \"e\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a? b?c:d : e", lexer_action=(_, _) => {
    ()
  })
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a?b?c:d:e<EOF>")
  assert_eq(
    printed.to_string(),
    "(s (e (e a) ? (e (e b) ? (e c) : (e d)) : (e e)) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "exit:e", "token:?", "enter:e", "enter:e",
    "token:b", "exit:e", "token:?", "enter:e", "token:c", "exit:e", "token::", "enter:e",
    "token:d", "exit:e", "exit:e", "token::", "enter:e", "token:e", "exit:e", "exit:e",
    "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "a", 0, 1, 1, 0, 0),
      (3, "?", 1, 2, 1, 1, 0),
      (6, "b", 3, 4, 1, 3, 0),
      (3, "?", 4, 5, 1, 4, 0),
      (6, "c", 5, 6, 1, 5, 0),
      (4, ":", 6, 7, 1, 6, 0),
      (6, "d", 7, 8, 1, 7, 0),
      (4, ":", 9, 10, 1, 9, 0),
      (6, "e", 11, 12, 1, 11, 0),
      (-1, "<EOF>", 12, 12, 1, 12, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion TernaryExprExplicitAssociativity_9" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u127.grammar()
  let parsed = grammar.parse_default(
    "a?b: c?d:e",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 10)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"a\") \"?\" (e \"b\") \":\" (e (e \"c\") \"?\" (e \"d\") \":\" (e \"e\"))) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a?b: c?d:e", lexer_action=(_, _) => {
    ()
  })
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a?b:c?d:e<EOF>")
  assert_eq(
    printed.to_string(),
    "(s (e (e a) ? (e b) : (e (e c) ? (e d) : (e e))) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:a", "exit:e", "token:?", "enter:e", "token:b",
    "exit:e", "token::", "enter:e", "enter:e", "token:c", "exit:e", "token:?", "enter:e",
    "token:d", "exit:e", "token::", "enter:e", "token:e", "exit:e", "exit:e", "exit:e",
    "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "a", 0, 1, 1, 0, 0),
      (3, "?", 1, 2, 1, 1, 0),
      (6, "b", 2, 3, 1, 2, 0),
      (4, ":", 3, 4, 1, 3, 0),
      (6, "c", 5, 6, 1, 5, 0),
      (3, "?", 6, 7, 1, 6, 0),
      (6, "d", 7, 8, 1, 7, 0),
      (4, ":", 8, 9, 1, 8, 0),
      (6, "e", 9, 10, 1, 9, 0),
      (-1, "<EOF>", 10, 10, 1, 10, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion WhitespaceInfluence_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u128.grammar()
  let parsed = grammar.parse_default(
    "Test(1,3)",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(prog (expression \"Test\" \"(\" (expression \"1\") \",\" (expression \"3\") \")\") <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("Test(1,3)", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "Test(1,3)<EOF>")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:prog", "enter:expression", "token:Test", "token:(", "enter:expression",
    "token:1", "exit:expression", "token:,", "enter:expression", "token:3", "exit:expression",
    "token:)", "exit:expression", "token:<EOF>", "exit:prog",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (21, "Test", 0, 4, 1, 0, 0),
      (1, "(", 4, 5, 1, 4, 0),
      (22, "1", 5, 6, 1, 5, 0),
      (2, ",", 6, 7, 1, 6, 0),
      (22, "3", 7, 8, 1, 7, 0),
      (3, ")", 8, 9, 1, 8, 0),
      (-1, "<EOF>", 9, 9, 1, 9, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LeftRecursion WhitespaceInfluence_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u129.grammar()
  let parsed = grammar.parse_default(
    "Test(1, 3)",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(prog (expression \"Test\" \"(\" (expression \"1\") \",\" (expression \"3\") \")\") <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("Test(1, 3)", lexer_action=(_, _) => {
    ()
  })
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "Test(1,3)<EOF>")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:prog", "enter:expression", "token:Test", "token:(", "enter:expression",
    "token:1", "exit:expression", "token:,", "enter:expression", "token:3", "exit:expression",
    "token:)", "exit:expression", "token:<EOF>", "exit:prog",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (21, "Test", 0, 4, 1, 0, 0),
      (1, "(", 4, 5, 1, 4, 0),
      (22, "1", 5, 6, 1, 5, 0),
      (2, ",", 6, 7, 1, 6, 0),
      (22, "3", 8, 9, 1, 8, 0),
      (3, ")", 9, 10, 1, 9, 0),
      (-1, "<EOF>", 10, 10, 1, 10, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerErrors DFAToATNThatFailsBackToDFA" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u130.lexer_data()).lexer_cursor(
    "ababx",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:1='ab',<1>,1:0]\n[@1,2:3='ab',<1>,1:2]\n[@2,5:4='<EOF>',<-1>,1:5]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "ab", 0, 2, 1, 0, 0),
      (1, "ab", 2, 4, 1, 2, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [(1, 4)],
  )
}

///|
test "upstream LexerErrors DFAToATNThatMatchesThenFailsInATN" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u131.lexer_data()).lexer_cursor(
    "ababcx",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:1='ab',<1>,1:0]\n[@1,2:4='abc',<2>,1:2]\n[@2,6:5='<EOF>',<-1>,1:6]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "ab", 0, 2, 1, 0, 0),
      (2, "abc", 2, 5, 1, 2, 0),
      (-1, "<EOF>", 6, 6, 1, 6, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [(1, 5)],
  )
}

///|
test "upstream LexerErrors EnforcedGreedyNestedBraces_1" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u132.lexer_data()).lexer_cursor(
    "{ { } }",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:6='{ { } }',<1>,1:0]\n[@1,7:6='<EOF>',<-1>,1:7]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "{ { } }", 0, 7, 1, 0, 0), (-1, "<EOF>", 7, 7, 1, 7, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerErrors EnforcedGreedyNestedBraces_2" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u133.lexer_data()).lexer_cursor(
    "{ { }",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(printed.to_string(), "[@0,5:4='<EOF>',<-1>,1:5]\n")
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(-1, "<EOF>", 5, 5, 1, 5, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [(1, 0)],
  )
}

///|
test "upstream LexerErrors ErrorInMiddle" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u134.lexer_data()).lexer_cursor(
    "abx",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(printed.to_string(), "[@0,3:2='<EOF>',<-1>,1:3]\n")
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(-1, "<EOF>", 3, 3, 1, 3, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [(1, 0)],
  )
}

///|
test "upstream LexerErrors InvalidCharAtStart" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u135.lexer_data()).lexer_cursor(
    "x",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(printed.to_string(), "[@0,1:0='<EOF>',<-1>,1:1]\n")
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [(1, 0)],
  )
}

///|
test "upstream LexerErrors InvalidCharAtStartAfterDFACache" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u136.lexer_data()).lexer_cursor(
    "abx",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:1='ab',<1>,1:0]\n[@1,3:2='<EOF>',<-1>,1:3]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "ab", 0, 2, 1, 0, 0), (-1, "<EOF>", 3, 3, 1, 3, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [(1, 2)],
  )
}

///|
test "upstream LexerErrors InvalidCharInToken" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u137.lexer_data()).lexer_cursor(
    "ax",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(printed.to_string(), "[@0,2:1='<EOF>',<-1>,1:2]\n")
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(-1, "<EOF>", 2, 2, 1, 2, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [(1, 0)],
  )
}

///|
test "upstream LexerErrors InvalidCharInTokenAfterDFACache" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u138.lexer_data()).lexer_cursor(
    "abax",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:1='ab',<1>,1:0]\n[@1,4:3='<EOF>',<-1>,1:4]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "ab", 0, 2, 1, 0, 0), (-1, "<EOF>", 4, 4, 1, 4, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [(1, 2)],
  )
}

///|
test "upstream LexerErrors LexerExecDFA" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u139.lexer_data()).lexer_cursor(
    "x : x",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:0='x',<3>,1:0]\n[@1,2:2=':',<1>,1:2]\n[@2,4:4='x',<3>,1:4]\n[@3,5:4='<EOF>',<-1>,1:5]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "x", 0, 1, 1, 0, 0),
      (1, ":", 2, 3, 1, 2, 0),
      (3, "x", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [(1, 1), (1, 3)],
  )
}

///|
test "upstream LexerErrors StringsEmbeddedInActions_1" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u140.lexer_data()).lexer_cursor(
    "[\"foo\"]",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:6='[\"foo\"]',<1>,1:0]\n[@1,7:6='<EOF>',<-1>,1:7]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "[\"foo\"]", 0, 7, 1, 0, 0), (-1, "<EOF>", 7, 7, 1, 7, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerErrors StringsEmbeddedInActions_2" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u141.lexer_data()).lexer_cursor(
    "[\"foo]",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(printed.to_string(), "[@0,6:5='<EOF>',<-1>,1:6]\n")
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(-1, "<EOF>", 6, 6, 1, 6, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [(1, 0)],
  )
}

///|
test "upstream LexerExec ActionPlacement" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      (0, 0) =>
        printed.write_string(
          "stuff fail: " +
          event.text.unwrap_or(
            String::from_array(
              source.to_array()[event.token_start:event.offset],
            ),
          ) +
          "\n",
        )
      (0, 1) =>
        printed.write_string(
          "stuff0:" +
          event.text.unwrap_or(
            String::from_array(
              source.to_array()[event.token_start:event.offset],
            ),
          ) +
          "\n",
        )
      (0, 2) =>
        printed.write_string(
          "stuff1: " +
          event.text.unwrap_or(
            String::from_array(
              source.to_array()[event.token_start:event.offset],
            ),
          ) +
          "\n",
        )
      (0, 3) =>
        printed.write_string(
          "stuff2: " +
          event.text.unwrap_or(
            String::from_array(
              source.to_array()[event.token_start:event.offset],
            ),
          ) +
          "\n",
        )
      (0, 4) =>
        printed.write_string(
          event.text.unwrap_or(
            String::from_array(
              source.to_array()[event.token_start:event.offset],
            ),
          ) +
          "\n",
        )
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u142.lexer_data()).lexer_cursor(
    "ab",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "stuff0:\nstuff1: a\nstuff2: ab\nab\n[@0,0:1='ab',<1>,1:0]\n[@1,2:1='<EOF>',<-1>,1:2]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "ab", 0, 2, 1, 0, 0), (-1, "<EOF>", 2, 2, 1, 2, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec CharSet" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      (0, 0) => printed.write_string("I" + "\n")
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u143.lexer_data()).lexer_cursor(
    "34\n 34",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "I\nI\n[@0,0:1='34',<1>,1:0]\n[@1,4:5='34',<1>,2:1]\n[@2,6:5='<EOF>',<-1>,2:3]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "34", 0, 2, 1, 0, 0),
      (1, "34", 4, 6, 2, 1, 0),
      (-1, "<EOF>", 6, 6, 2, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec CharSetInSet" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      (0, 0) => printed.write_string("I" + "\n")
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u144.lexer_data()).lexer_cursor(
    "a x",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "I\nI\n[@0,0:0='a',<1>,1:0]\n[@1,2:2='x',<1>,1:2]\n[@2,3:2='<EOF>',<-1>,1:3]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (1, "x", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec CharSetNot" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      (0, 0) => printed.write_string("I" + "\n")
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u145.lexer_data()).lexer_cursor(
    "xaf",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "I\n[@0,0:2='xaf',<1>,1:0]\n[@1,3:2='<EOF>',<-1>,1:3]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "xaf", 0, 3, 1, 0, 0), (-1, "<EOF>", 3, 3, 1, 3, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec CharSetPlus" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      (0, 0) => printed.write_string("I" + "\n")
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u146.lexer_data()).lexer_cursor(
    "34\n 34",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "I\nI\n[@0,0:1='34',<1>,1:0]\n[@1,4:5='34',<1>,2:1]\n[@2,6:5='<EOF>',<-1>,2:3]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "34", 0, 2, 1, 0, 0),
      (1, "34", 4, 6, 2, 1, 0),
      (-1, "<EOF>", 6, 6, 2, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec CharSetRange" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      (0, 0) => printed.write_string("I" + "\n")
      (1, 1) => printed.write_string("ID" + "\n")
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u147.lexer_data()).lexer_cursor(
    "34\n 34 a2 abc \n   ",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "I\nI\nID\nID\n[@0,0:1='34',<1>,1:0]\n[@1,4:5='34',<1>,2:1]\n[@2,7:8='a2',<2>,2:4]\n[@3,10:12='abc',<2>,2:7]\n[@4,18:17='<EOF>',<-1>,3:3]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "34", 0, 2, 1, 0, 0),
      (1, "34", 4, 6, 2, 1, 0),
      (2, "a2", 7, 9, 2, 4, 0),
      (2, "abc", 10, 13, 2, 7, 0),
      (-1, "<EOF>", 18, 18, 3, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec CharSetWithEscapedChar" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      (0, 0) => printed.write_string("DASHBRACK" + "\n")
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u148.lexer_data()).lexer_cursor(
    "- ] ",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "DASHBRACK\nDASHBRACK\n[@0,0:0='-',<1>,1:0]\n[@1,2:2=']',<1>,1:2]\n[@2,4:3='<EOF>',<-1>,1:4]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "-", 0, 1, 1, 0, 0),
      (1, "]", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 4, 4, 1, 4, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec CharSetWithMissingEscapeChar" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      (0, 0) => printed.write_string("I" + "\n")
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u149.lexer_data()).lexer_cursor(
    "34 ",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "I\n[@0,0:1='34',<1>,1:0]\n[@1,3:2='<EOF>',<-1>,1:3]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "34", 0, 2, 1, 0, 0), (-1, "<EOF>", 3, 3, 1, 3, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec CharSetWithQuote1" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      (0, 0) => printed.write_string("A" + "\n")
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u150.lexer_data()).lexer_cursor(
    "b\"a",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "A\n[@0,0:2='b\"a',<1>,1:0]\n[@1,3:2='<EOF>',<-1>,1:3]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "b\"a", 0, 3, 1, 0, 0), (-1, "<EOF>", 3, 3, 1, 3, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec CharSetWithQuote2" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      (0, 0) => printed.write_string("A" + "\n")
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u151.lexer_data()).lexer_cursor(
    "b\"\\a",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "A\n[@0,0:3='b\"\\a',<1>,1:0]\n[@1,4:3='<EOF>',<-1>,1:4]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "b\"\\a", 0, 4, 1, 0, 0), (-1, "<EOF>", 4, 4, 1, 4, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec EOFByItself" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u152.lexer_data()).lexer_cursor(
    "",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:-1='<EOF>',<1>,1:0]\n[@1,0:-1='<EOF>',<-1>,1:0]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "<EOF>", 0, 0, 1, 0, 0), (-1, "<EOF>", 0, 0, 1, 0, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec EOFSuffixInFirstRule_1" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u153.lexer_data()).lexer_cursor(
    "",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(printed.to_string(), "[@0,0:-1='<EOF>',<-1>,1:0]\n")
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(-1, "<EOF>", 0, 0, 1, 0, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec EOFSuffixInFirstRule_2" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u154.lexer_data()).lexer_cursor(
    "a",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:0='a',<1>,1:0]\n[@1,1:0='<EOF>',<-1>,1:1]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "a", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec EscapedCharacters" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u155.lexer_data()).lexer_cursor(
    "x\n",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:0='x',<2>,1:0]\n[@1,1:1='\\n',<1>,1:1]\n[@2,2:1='<EOF>',<-1>,2:0]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "x", 0, 1, 1, 0, 0),
      (1, "\n", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 2, 0, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec EscapeTargetStringLiteral" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u156.lexer_data()).lexer_cursor(
    "",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(printed.to_string(), "[@0,0:-1='<EOF>',<-1>,1:0]\n")
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(-1, "<EOF>", 0, 0, 1, 0, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec GreedyClosure" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u157.lexer_data()).lexer_cursor(
    "//blah\n//blah\n",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:13='//blah\\n//blah\\n',<1>,1:0]\n[@1,14:13='<EOF>',<-1>,3:0]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "//blah\n//blah\n", 0, 14, 1, 0, 0), (-1, "<EOF>", 14, 14, 3, 0, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec GreedyConfigs" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      (0, 0) =>
        printed.write_string(
          event.text.unwrap_or(
            String::from_array(
              source.to_array()[event.token_start:event.offset],
            ),
          ) +
          "\n",
        )
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u158.lexer_data()).lexer_cursor(
    "ab",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "ab\n[@0,0:1='ab',<1>,1:0]\n[@1,2:1='<EOF>',<-1>,1:2]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "ab", 0, 2, 1, 0, 0), (-1, "<EOF>", 2, 2, 1, 2, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec GreedyOptional" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u159.lexer_data()).lexer_cursor(
    "//blah\n//blah\n",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:13='//blah\\n//blah\\n',<1>,1:0]\n[@1,14:13='<EOF>',<-1>,3:0]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "//blah\n//blah\n", 0, 14, 1, 0, 0), (-1, "<EOF>", 14, 14, 3, 0, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec GreedyPositiveClosure" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u160.lexer_data()).lexer_cursor(
    "//blah\n//blah\n",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:13='//blah\\n//blah\\n',<1>,1:0]\n[@1,14:13='<EOF>',<-1>,3:0]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "//blah\n//blah\n", 0, 14, 1, 0, 0), (-1, "<EOF>", 14, 14, 3, 0, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec HexVsID" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u161.lexer_data()).lexer_cursor(
    "x 0 1 a.b a.l",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:0='x',<5>,1:0]\n[@1,1:1=' ',<6>,1:1]\n[@2,2:2='0',<2>,1:2]\n[@3,3:3=' ',<6>,1:3]\n[@4,4:4='1',<2>,1:4]\n[@5,5:5=' ',<6>,1:5]\n[@6,6:6='a',<5>,1:6]\n[@7,7:7='.',<4>,1:7]\n[@8,8:8='b',<5>,1:8]\n[@9,9:9=' ',<6>,1:9]\n[@10,10:10='a',<5>,1:10]\n[@11,11:11='.',<4>,1:11]\n[@12,12:12='l',<5>,1:12]\n[@13,13:12='<EOF>',<-1>,1:13]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (5, "x", 0, 1, 1, 0, 0),
      (6, " ", 1, 2, 1, 1, 0),
      (2, "0", 2, 3, 1, 2, 0),
      (6, " ", 3, 4, 1, 3, 0),
      (2, "1", 4, 5, 1, 4, 0),
      (6, " ", 5, 6, 1, 5, 0),
      (5, "a", 6, 7, 1, 6, 0),
      (4, ".", 7, 8, 1, 7, 0),
      (5, "b", 8, 9, 1, 8, 0),
      (6, " ", 9, 10, 1, 9, 0),
      (5, "a", 10, 11, 1, 10, 0),
      (4, ".", 11, 12, 1, 11, 0),
      (5, "l", 12, 13, 1, 12, 0),
      (-1, "<EOF>", 13, 13, 1, 13, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec KeywordID" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u162.lexer_data()).lexer_cursor(
    "end eend ending a",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:2='end',<1>,1:0]\n[@1,3:3=' ',<3>,1:3]\n[@2,4:7='eend',<2>,1:4]\n[@3,8:8=' ',<3>,1:8]\n[@4,9:14='ending',<2>,1:9]\n[@5,15:15=' ',<3>,1:15]\n[@6,16:16='a',<2>,1:16]\n[@7,17:16='<EOF>',<-1>,1:17]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "end", 0, 3, 1, 0, 0),
      (3, " ", 3, 4, 1, 3, 0),
      (2, "eend", 4, 8, 1, 4, 0),
      (3, " ", 8, 9, 1, 8, 0),
      (2, "ending", 9, 15, 1, 9, 0),
      (3, " ", 15, 16, 1, 15, 0),
      (2, "a", 16, 17, 1, 16, 0),
      (-1, "<EOF>", 17, 17, 1, 17, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec NonGreedyClosure" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u163.lexer_data()).lexer_cursor(
    "//blah\n//blah\n",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:6='//blah\\n',<1>,1:0]\n[@1,7:13='//blah\\n',<1>,2:0]\n[@2,14:13='<EOF>',<-1>,3:0]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "//blah\n", 0, 7, 1, 0, 0),
      (1, "//blah\n", 7, 14, 2, 0, 0),
      (-1, "<EOF>", 14, 14, 3, 0, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec NonGreedyConfigs" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      (0, 0) =>
        printed.write_string(
          event.text.unwrap_or(
            String::from_array(
              source.to_array()[event.token_start:event.offset],
            ),
          ) +
          "\n",
        )
      (2, 1) =>
        printed.write_string(
          event.text.unwrap_or(
            String::from_array(
              source.to_array()[event.token_start:event.offset],
            ),
          ) +
          "\n",
        )
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u164.lexer_data()).lexer_cursor(
    "ab",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "a\nb\n[@0,0:0='a',<1>,1:0]\n[@1,1:1='b',<3>,1:1]\n[@2,2:1='<EOF>',<-1>,1:2]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (3, "b", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec NonGreedyOptional" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u165.lexer_data()).lexer_cursor(
    "//blah\n//blah\n",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:6='//blah\\n',<1>,1:0]\n[@1,7:13='//blah\\n',<1>,2:0]\n[@2,14:13='<EOF>',<-1>,3:0]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "//blah\n", 0, 7, 1, 0, 0),
      (1, "//blah\n", 7, 14, 2, 0, 0),
      (-1, "<EOF>", 14, 14, 3, 0, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec NonGreedyPositiveClosure" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u166.lexer_data()).lexer_cursor(
    "//blah\n//blah\n",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:6='//blah\\n',<1>,1:0]\n[@1,7:13='//blah\\n',<1>,2:0]\n[@2,14:13='<EOF>',<-1>,3:0]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "//blah\n", 0, 7, 1, 0, 0),
      (1, "//blah\n", 7, 14, 2, 0, 0),
      (-1, "<EOF>", 14, 14, 3, 0, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec NonGreedyTermination1" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u167.lexer_data()).lexer_cursor(
    "!hi!!mom!",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:3='!hi!',<1>,1:0]\n[@1,4:8='!mom!',<1>,1:4]\n[@2,9:8='<EOF>',<-1>,1:9]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "!hi!", 0, 4, 1, 0, 0),
      (1, "!mom!", 4, 9, 1, 4, 0),
      (-1, "<EOF>", 9, 9, 1, 9, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec NonGreedyTermination2" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u168.lexer_data()).lexer_cursor(
    "!!!mom!",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:6='!!!mom!',<1>,1:0]\n[@1,7:6='<EOF>',<-1>,1:7]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "!!!mom!", 0, 7, 1, 0, 0), (-1, "<EOF>", 7, 7, 1, 7, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec Parentheses" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u169.lexer_data()).lexer_cursor(
    "-.-.-!",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:4='-.-.-',<1>,1:0]\n[@1,5:5='!',<3>,1:5]\n[@2,6:5='<EOF>',<-1>,1:6]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "-.-.-", 0, 5, 1, 0, 0),
      (3, "!", 5, 6, 1, 5, 0),
      (-1, "<EOF>", 6, 6, 1, 6, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec PositionAdjustingLexer" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  ignore(lexer_observer)
  let lexed = position_adjusted_tokens(
    @u170.lexer_data(),
    "tokens\ntokens {\nnotLabel\nlabel1 =\nlabel2 +=\nnotLabel\n",
    4,
    5,
  )
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:5='tokens',<6>,1:0]\n[@1,7:12='tokens',<4>,2:0]\n[@2,14:14='{',<3>,2:7]\n[@3,16:23='notLabel',<6>,3:0]\n[@4,25:30='label1',<5>,4:0]\n[@5,32:32='=',<1>,4:7]\n[@6,34:39='label2',<5>,5:0]\n[@7,41:42='+=',<2>,5:7]\n[@8,44:51='notLabel',<6>,6:0]\n[@9,53:52='<EOF>',<-1>,7:0]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "tokens", 0, 6, 1, 0, 0),
      (4, "tokens", 7, 13, 2, 0, 0),
      (3, "{", 14, 15, 2, 7, 0),
      (6, "notLabel", 16, 24, 3, 0, 0),
      (5, "label1", 25, 31, 4, 0, 0),
      (1, "=", 32, 33, 4, 7, 0),
      (5, "label2", 34, 40, 5, 0, 0),
      (2, "+=", 41, 43, 5, 7, 0),
      (6, "notLabel", 44, 52, 6, 0, 0),
      (-1, "<EOF>", 53, 53, 7, 0, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec QuoteTranslation" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u171.lexer_data()).lexer_cursor(
    "\"",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:0='\"',<1>,1:0]\n[@1,1:0='<EOF>',<-1>,1:1]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "\"", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec RecursiveLexerRuleRefWithWildcardPlus_1" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u172.lexer_data()).lexer_cursor(
    "/* ick */\n/* /* */\n/* /*nested*/ */\n",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:8='/* ick */',<1>,1:0]\n[@1,9:9='\\n',<2>,1:9]\n[@2,10:34='/* /* */\\n/* /*nested*/ */',<1>,2:0]\n[@3,35:35='\\n',<2>,3:16]\n[@4,36:35='<EOF>',<-1>,4:0]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "/* ick */", 0, 9, 1, 0, 0),
      (2, "\n", 9, 10, 1, 9, 0),
      (1, "/* /* */\n/* /*nested*/ */", 10, 35, 2, 0, 0),
      (2, "\n", 35, 36, 3, 16, 0),
      (-1, "<EOF>", 36, 36, 4, 0, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec RecursiveLexerRuleRefWithWildcardPlus_2" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u173.lexer_data()).lexer_cursor(
    "/* ick */x\n/* /* */x\n/* /*nested*/ */x\n",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:8='/* ick */',<1>,1:0]\n[@1,10:10='\\n',<2>,1:10]\n[@2,11:36='/* /* */x\\n/* /*nested*/ */',<1>,2:0]\n[@3,38:38='\\n',<2>,3:17]\n[@4,39:38='<EOF>',<-1>,4:0]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "/* ick */", 0, 9, 1, 0, 0),
      (2, "\n", 10, 11, 1, 10, 0),
      (1, "/* /* */x\n/* /*nested*/ */", 11, 37, 2, 0, 0),
      (2, "\n", 38, 39, 3, 17, 0),
      (-1, "<EOF>", 39, 39, 4, 0, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [(1, 9), (3, 16)],
  )
}

///|
test "upstream LexerExec RecursiveLexerRuleRefWithWildcardStar_1" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u174.lexer_data()).lexer_cursor(
    "/* ick */\n/* /* */\n/* /*nested*/ */\n",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:8='/* ick */',<1>,1:0]\n[@1,9:9='\\n',<2>,1:9]\n[@2,10:34='/* /* */\\n/* /*nested*/ */',<1>,2:0]\n[@3,35:35='\\n',<2>,3:16]\n[@4,36:35='<EOF>',<-1>,4:0]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "/* ick */", 0, 9, 1, 0, 0),
      (2, "\n", 9, 10, 1, 9, 0),
      (1, "/* /* */\n/* /*nested*/ */", 10, 35, 2, 0, 0),
      (2, "\n", 35, 36, 3, 16, 0),
      (-1, "<EOF>", 36, 36, 4, 0, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec RecursiveLexerRuleRefWithWildcardStar_2" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u175.lexer_data()).lexer_cursor(
    "/* ick */x\n/* /* */x\n/* /*nested*/ */x\n",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:8='/* ick */',<1>,1:0]\n[@1,10:10='\\n',<2>,1:10]\n[@2,11:36='/* /* */x\\n/* /*nested*/ */',<1>,2:0]\n[@3,38:38='\\n',<2>,3:17]\n[@4,39:38='<EOF>',<-1>,4:0]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "/* ick */", 0, 9, 1, 0, 0),
      (2, "\n", 10, 11, 1, 10, 0),
      (1, "/* /* */x\n/* /*nested*/ */", 11, 37, 2, 0, 0),
      (2, "\n", 38, 39, 3, 17, 0),
      (-1, "<EOF>", 39, 39, 4, 0, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [(1, 9), (3, 16)],
  )
}

///|
test "upstream LexerExec RefToRuleDoesNotSetTokenNorEmitAnother" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u176.lexer_data()).lexer_cursor(
    "34 -21 3",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:1='34',<2>,1:0]\n[@1,3:5='-21',<1>,1:3]\n[@2,7:7='3',<2>,1:7]\n[@3,8:7='<EOF>',<-1>,1:8]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "34", 0, 2, 1, 0, 0),
      (1, "-21", 3, 6, 1, 3, 0),
      (2, "3", 7, 8, 1, 7, 0),
      (-1, "<EOF>", 8, 8, 1, 8, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec ReservedWordsEscaping" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u177.lexer_data()).lexer_cursor(
    "ab",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:0='a',<1>,1:0]\n[@1,1:1='b',<2>,channel=2,1:1]\n[@2,2:1='<EOF>',<-1>,1:2]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (2, "b", 1, 2, 1, 1, 2),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec ReservedWordsEscaping_NULL" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u178.lexer_data()).lexer_cursor(
    "NULL",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:3='NULL',<1>,1:0]\n[@1,4:3='<EOF>',<-1>,1:4]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "NULL", 0, 4, 1, 0, 0), (-1, "<EOF>", 4, 4, 1, 4, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec Slashes" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u179.lexer_data()).lexer_cursor(
    "\\ / \\/ /\\",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:0='\\',<1>,1:0]\n[@1,2:2='/',<2>,1:2]\n[@2,4:5='\\/',<3>,1:4]\n[@3,7:8='/\\',<4>,1:7]\n[@4,9:8='<EOF>',<-1>,1:9]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "\\", 0, 1, 1, 0, 0),
      (2, "/", 2, 3, 1, 2, 0),
      (3, "\\/", 4, 6, 1, 4, 0),
      (4, "/\\", 7, 9, 1, 7, 0),
      (-1, "<EOF>", 9, 9, 1, 9, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec StackoverflowDueToNotEscapedHyphen" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u180.lexer_data()).lexer_cursor(
    "word",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:3='word',<1>,1:0]\n[@1,4:3='<EOF>',<-1>,1:4]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "word", 0, 4, 1, 0, 0), (-1, "<EOF>", 4, 4, 1, 4, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec TokenType0xFFFF" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u181.lexer_data()).lexer_cursor(
    "FFFF",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:3='FFFF',<65535>,1:0]\n[@1,4:3='<EOF>',<-1>,1:4]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(65535, "FFFF", 0, 4, 1, 0, 0), (-1, "<EOF>", 4, 4, 1, 4, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec UnicodeCharSet" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u182.lexer_data()).lexer_cursor(
    "均",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:0='均',<1>,1:0]\n[@1,1:0='<EOF>',<-1>,1:1]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "均", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream LexerExec ZeroLengthToken" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let cursor = @runtime.deserialize(@u183.lexer_data()).lexer_cursor(
    "'xxx'",
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:4=''xxx'',<1>,1:0]\n[@1,5:4='<EOF>',<-1>,1:5]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "'xxx'", 0, 5, 1, 0, 0), (-1, "<EOF>", 5, 5, 1, 5, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Listeners Basic" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => {
          printed.write_string(
            observed_tree(observed_context(event, "r", [4])) + "\n",
          )
          observed_walk(
            observed_context(event, "r", [4]),
            "Basic",
            event.tokens,
            3,
            4,
            [4],
            printed,
          )
        }
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u184.grammar()
  let parsed = grammar.parse_default(
    "1 2",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"1\" \"2\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("1 2", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "12")
  assert_eq(printed.to_string(), "(a 1 2)\n1\n2\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:1", "token:2", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "1", 0, 1, 1, 0, 0),
      (3, "2", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Listeners LR" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => {
          printed.write_string(
            observed_tree(observed_context(event, "r", [4])) + "\n",
          )
          observed_walk(
            observed_context(event, "r", [4]),
            "LR",
            event.tokens,
            3,
            4,
            [4],
            printed,
          )
        }
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u185.grammar()
  let parsed = grammar.parse_default(
    "1+2*3",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"1\") \"+\" (e (e \"2\") \"*\" (e \"3\"))))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("1+2*3", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "1+2*3")
  assert_eq(
    printed.to_string(),
    "(e (e 1) + (e (e 2) * (e 3)))\n1\n2\n3\n2 3 2\n1 2 1\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:1", "exit:e", "token:+", "enter:e", "enter:e",
    "token:2", "exit:e", "token:*", "enter:e", "token:3", "exit:e", "exit:e", "exit:e",
    "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "1", 0, 1, 1, 0, 0),
      (2, "+", 1, 2, 1, 1, 0),
      (3, "2", 2, 3, 1, 2, 0),
      (1, "*", 3, 4, 1, 3, 0),
      (3, "3", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Listeners LRWithLabels" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => {
          printed.write_string(
            observed_tree(observed_context(event, "r", [6])) + "\n",
          )
          observed_walk(
            observed_context(event, "r", [6]),
            "LRWithLabels",
            event.tokens,
            6,
            7,
            [6],
            printed,
          )
        }
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u186.grammar()
  let parsed = grammar.parse_default(
    "1(2,3)",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 6)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (e (e \"1\") \"(\" (eList (e \"2\") \",\" (e \"3\")) \")\"))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("1(2,3)", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "1(2,3)")
  assert_eq(
    printed.to_string(),
    "(e (e 1) ( (eList (e 2) , (e 3)) ))\n1\n2\n3\n1 [13 6]\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "enter:e", "token:1", "exit:e", "token:(", "enter:eList",
    "enter:e", "token:2", "exit:e", "token:,", "enter:e", "token:3", "exit:e", "exit:eList",
    "token:)", "exit:e", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "1", 0, 1, 1, 0, 0),
      (1, "(", 1, 2, 1, 1, 0),
      (6, "2", 2, 3, 1, 2, 0),
      (3, ",", 3, 4, 1, 3, 0),
      (6, "3", 4, 5, 1, 4, 0),
      (2, ")", 5, 6, 1, 5, 0),
      (-1, "<EOF>", 6, 6, 1, 6, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Listeners RuleGetters_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => {
          printed.write_string(
            observed_tree(observed_context(event, "r", [6])) + "\n",
          )
          observed_walk(
            observed_context(event, "r", [6]),
            "RuleGetter",
            event.tokens,
            3,
            4,
            [6],
            printed,
          )
        }
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u187.grammar()
  let parsed = grammar.parse_default(
    "1 2",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a (b \"1\") (b \"2\")))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("1 2", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "12")
  assert_eq(printed.to_string(), "(a (b 1) (b 2))\n1 2 1\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "enter:b", "token:1", "exit:b", "enter:b", "token:2", "exit:b",
    "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "1", 0, 1, 1, 0, 0),
      (3, "2", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Listeners RuleGetters_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => {
          printed.write_string(
            observed_tree(observed_context(event, "r", [6])) + "\n",
          )
          observed_walk(
            observed_context(event, "r", [6]),
            "RuleGetter",
            event.tokens,
            3,
            4,
            [6],
            printed,
          )
        }
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u188.grammar()
  let parsed = grammar.parse_default(
    "abc",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a (b \"abc\")))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("abc", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "abc")
  assert_eq(printed.to_string(), "(a (b abc))\nabc\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "enter:b", "token:abc", "exit:b", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(4, "abc", 0, 3, 1, 0, 0), (-1, "<EOF>", 3, 3, 1, 3, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Listeners TokenGetters_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => {
          printed.write_string(
            observed_tree(observed_context(event, "r", [4])) + "\n",
          )
          observed_walk(
            observed_context(event, "r", [4]),
            "TokenGetter",
            event.tokens,
            3,
            4,
            [4],
            printed,
          )
        }
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u189.grammar()
  let parsed = grammar.parse_default(
    "1 2",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"1\" \"2\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("1 2", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "12")
  assert_eq(printed.to_string(), "(a 1 2)\n1 2 [1, 2]\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:1", "token:2", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "1", 0, 1, 1, 0, 0),
      (3, "2", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Listeners TokenGetters_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => {
          printed.write_string(
            observed_tree(observed_context(event, "r", [4])) + "\n",
          )
          observed_walk(
            observed_context(event, "r", [4]),
            "TokenGetter",
            event.tokens,
            3,
            4,
            [4],
            printed,
          )
        }
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u190.grammar()
  let parsed = grammar.parse_default(
    "abc",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"abc\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("abc", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "abc")
  assert_eq(printed.to_string(), "(a abc)\n[@0,0:2='abc',<4>,1:0]\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:abc", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(4, "abc", 0, 3, 1, 0, 0), (-1, "<EOF>", 3, 3, 1, 3, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors ConjuringUpToken" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(
            "conjured=" +
            observed_token_string(observed_token(event, 0, [3]), event.tokens) +
            "\n",
          )
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u191.grammar()
  let parsed = grammar.parse_default(
    "ac",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a\" (error \"<missing 'b'>\") \"c\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(1)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(2, "<missing 'b'>", -1, 0, 1, 1, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("ac", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "a<missing 'b'>c")
  assert_eq(
    printed.to_string(),
    "conjured=[@-1,-1:-1='<missing 'b'>',<2>,1:1]\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "error:<missing 'b'>", "token:c", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (3, "c", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors ConjuringUpTokenFromSet" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(
            "conjured=" +
            observed_token_string(observed_token(event, 0, [3]), event.tokens) +
            "\n",
          )
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u192.grammar()
  let parsed = grammar.parse_default(
    "ad",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a\" \"d\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(1)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("ad", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "ad")
  assert_eq(
    printed.to_string(),
    "conjured=[@-1,-1:-1='<missing 'b'>',<2>,1:1]\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "token:d", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (4, "d", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors ContextListGetters" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("a")
        1 => printed.write_string("b")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u193.grammar()
  let parsed = grammar.parse_default(
    "abab",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1), (1, 2), (0, 3), (1, 4)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (a \"a\") (b \"b\") (a \"a\") (b \"b\"))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("abab", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "abab")
  assert_eq(printed.to_string(), "abab")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:a", "exit:a", "enter:b", "token:b", "exit:b", "enter:a",
    "token:a", "exit:a", "enter:b", "token:b", "exit:b", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (2, "b", 1, 2, 1, 1, 0),
      (1, "a", 2, 3, 1, 2, 0),
      (2, "b", 3, 4, 1, 3, 0),
      (-1, "<EOF>", 4, 4, 1, 4, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors DuplicatedLeftRecursiveCall_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u194.grammar()
  let parsed = grammar.parse_default(
    "x",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(start (expr \"x\") <EOF>)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "x<EOF>")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:start", "enter:expr", "token:x", "exit:expr", "token:<EOF>", "exit:start",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "x", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors DuplicatedLeftRecursiveCall_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u195.grammar()
  let parsed = grammar.parse_default(
    "xx",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(start (expr (expr \"x\") (expr \"x\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("xx", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "xx<EOF>")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:start", "enter:expr", "enter:expr", "token:x", "exit:expr", "enter:expr",
    "token:x", "exit:expr", "exit:expr", "token:<EOF>", "exit:start",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "x", 0, 1, 1, 0, 0),
      (1, "x", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors DuplicatedLeftRecursiveCall_3" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u196.grammar()
  let parsed = grammar.parse_default(
    "xxx",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(start (expr (expr (expr \"x\") (expr \"x\")) (expr \"x\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("xxx", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "xxx<EOF>")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:start", "enter:expr", "enter:expr", "enter:expr", "token:x", "exit:expr",
    "enter:expr", "token:x", "exit:expr", "exit:expr", "enter:expr", "token:x", "exit:expr",
    "exit:expr", "token:<EOF>", "exit:start",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "x", 0, 1, 1, 0, 0),
      (1, "x", 1, 2, 1, 1, 0),
      (1, "x", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors DuplicatedLeftRecursiveCall_4" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u197.grammar()
  let parsed = grammar.parse_default(
    "xxxx",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(start (expr (expr (expr (expr \"x\") (expr \"x\")) (expr \"x\")) (expr \"x\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("xxxx", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "xxxx<EOF>")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:start", "enter:expr", "enter:expr", "enter:expr", "enter:expr", "token:x",
    "exit:expr", "enter:expr", "token:x", "exit:expr", "exit:expr", "enter:expr",
    "token:x", "exit:expr", "exit:expr", "enter:expr", "token:x", "exit:expr", "exit:expr",
    "token:<EOF>", "exit:start",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "x", 0, 1, 1, 0, 0),
      (1, "x", 1, 2, 1, 1, 0),
      (1, "x", 2, 3, 1, 2, 0),
      (1, "x", 3, 4, 1, 3, 0),
      (-1, "<EOF>", 4, 4, 1, 4, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors ExtraneousInput" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u198.grammar()
  let parsed = grammar.parse_default(
    "baa",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=2,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(file (body) (error \"b\") (error \"a\") (error \"a\"))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(0)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(2, "b", 0, 1, 1, 0, 0), (1, "a", 1, 2, 1, 1, 0), (1, "a", 2, 3, 1, 2, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("baa", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "baa")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:file", "enter:body", "exit:body", "error:b", "error:a", "error:a", "exit:file",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "b", 0, 1, 1, 0, 0),
      (1, "a", 1, 2, 1, 1, 0),
      (1, "a", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors InvalidATNStateRemoval" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u199.grammar()
  let parsed = grammar.parse_default(
    "x:x",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(start \"x\" \":\" (expr (primary \"x\")))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x:x", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "x:x")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:start", "token:x", "token::", "enter:expr", "enter:primary", "token:x",
    "exit:primary", "exit:expr", "exit:start",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "x", 0, 1, 1, 0, 0),
      (1, ":", 1, 2, 1, 1, 0),
      (3, "x", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors InvalidEmptyInput" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u200.grammar()
  let parsed = grammar.parse_default(
    "",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(start)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(0)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:start", "exit:start",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(-1, "<EOF>", 0, 0, 1, 0, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors LL1ErrorInfo" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(
            observed_expected(event, [
              "0", "'and'", "'dog'", "'cat'", "'hardware'", "'software'", "' '",
            ]) +
            "\n",
          )
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u201.grammar()
  let parsed = grammar.parse_default(
    "dog and software",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 8)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(start (animal \"dog\") \"and\" (acClass) (service \"software\") <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("dog and software", lexer_action=(
    _,
    _,
  ) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "dogandsoftware<EOF>")
  assert_eq(printed.to_string(), "{'hardware', 'software'}\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:start", "enter:animal", "token:dog", "exit:animal", "token:and", "enter:acClass",
    "exit:acClass", "enter:service", "token:software", "exit:service", "token:<EOF>",
    "exit:start",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "dog", 0, 3, 1, 0, 0),
      (1, "and", 4, 7, 1, 4, 0),
      (5, "software", 8, 16, 1, 8, 0),
      (-1, "<EOF>", 16, 16, 1, 16, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors LL2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u202.grammar()
  let parsed = grammar.parse_default(
    "ae",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(a (error \"a\") (error \"e\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(1)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(1, "a", 0, 1, 1, 0, 0), (4, "e", 1, 2, 1, 1, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("ae", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "ae")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "error:a", "error:e", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (4, "e", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors LL3" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u203.grammar()
  let parsed = grammar.parse_default(
    "abe",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(a (error \"a\") (error \"b\") (error \"e\"))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(2)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(1, "a", 0, 1, 1, 0, 0), (2, "b", 1, 2, 1, 1, 0), (5, "e", 2, 3, 1, 2, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("abe", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "abe")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "error:a", "error:b", "error:e", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (2, "b", 1, 2, 1, 1, 0),
      (5, "e", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors LLStar" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u204.grammar()
  let parsed = grammar.parse_default(
    "aaae",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(a (error \"a\") (error \"a\") (error \"a\") (error \"e\"))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(3)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (1, "a", 1, 2, 1, 1, 0),
      (1, "a", 2, 3, 1, 2, 0),
      (4, "e", 3, 4, 1, 3, 0),
    ],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("aaae", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "aaae")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "error:a", "error:a", "error:a", "error:e", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (1, "a", 1, 2, 1, 1, 0),
      (1, "a", 2, 3, 1, 2, 0),
      (4, "e", 3, 4, 1, 3, 0),
      (-1, "<EOF>", 4, 4, 1, 4, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors MultiTokenDeletionBeforeLoop" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u205.grammar()
  let parsed = grammar.parse_default(
    "aacabc",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a\" (error \"a\") \"c\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(1)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(1, "a", 1, 2, 1, 1, 0)],
  )
  assert_eq(parsed.next_token.kind, 1)
  assert_eq(parsed.next_token.text, "a")
  let lexed = grammar.tokenize_recovering("aacabc", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "aac")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "error:a", "token:c", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (1, "a", 1, 2, 1, 1, 0),
      (3, "c", 2, 3, 1, 2, 0),
      (1, "a", 3, 4, 1, 3, 0),
      (2, "b", 4, 5, 1, 4, 0),
      (3, "c", 5, 6, 1, 5, 0),
      (-1, "<EOF>", 6, 6, 1, 6, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors MultiTokenDeletionBeforeLoop2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u206.grammar()
  let parsed = grammar.parse_default(
    "aacabc",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a\" (error \"a\") \"c\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(1)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(1, "a", 1, 2, 1, 1, 0)],
  )
  assert_eq(parsed.next_token.kind, 1)
  assert_eq(parsed.next_token.text, "a")
  let lexed = grammar.tokenize_recovering("aacabc", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "aac")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "error:a", "token:c", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (1, "a", 1, 2, 1, 1, 0),
      (4, "c", 2, 3, 1, 2, 0),
      (1, "a", 3, 4, 1, 3, 0),
      (2, "b", 4, 5, 1, 4, 0),
      (4, "c", 5, 6, 1, 5, 0),
      (-1, "<EOF>", 6, 6, 1, 6, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors MultiTokenDeletionDuringLoop" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u207.grammar()
  let parsed = grammar.parse_default(
    "abaaababc",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(a \"a\" \"b\" (error \"a\") (error \"a\") (error \"a\") \"b\" (error \"a\") \"b\" \"c\")",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(2)),
    (Some(1), Some(6)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [
      (1, "a", 2, 3, 1, 2, 0),
      (1, "a", 3, 4, 1, 3, 0),
      (1, "a", 4, 5, 1, 4, 0),
      (1, "a", 6, 7, 1, 6, 0),
    ],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("abaaababc", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "abaaababc")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "token:b", "error:a", "error:a", "error:a", "token:b",
    "error:a", "token:b", "token:c", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (2, "b", 1, 2, 1, 1, 0),
      (1, "a", 2, 3, 1, 2, 0),
      (1, "a", 3, 4, 1, 3, 0),
      (1, "a", 4, 5, 1, 4, 0),
      (2, "b", 5, 6, 1, 5, 0),
      (1, "a", 6, 7, 1, 6, 0),
      (2, "b", 7, 8, 1, 7, 0),
      (3, "c", 8, 9, 1, 8, 0),
      (-1, "<EOF>", 9, 9, 1, 9, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors MultiTokenDeletionDuringLoop2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u208.grammar()
  let parsed = grammar.parse_default(
    "abaaababc",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(a \"a\" \"b\" (error \"a\") (error \"a\") (error \"a\") \"b\" (error \"a\") \"b\" \"c\")",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(2)),
    (Some(1), Some(6)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [
      (1, "a", 2, 3, 1, 2, 0),
      (1, "a", 3, 4, 1, 3, 0),
      (1, "a", 4, 5, 1, 4, 0),
      (1, "a", 6, 7, 1, 6, 0),
    ],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("abaaababc", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "abaaababc")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "token:b", "error:a", "error:a", "error:a", "token:b",
    "error:a", "token:b", "token:c", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (2, "b", 1, 2, 1, 1, 0),
      (1, "a", 2, 3, 1, 2, 0),
      (1, "a", 3, 4, 1, 3, 0),
      (1, "a", 4, 5, 1, 4, 0),
      (2, "b", 5, 6, 1, 5, 0),
      (1, "a", 6, 7, 1, 6, 0),
      (2, "b", 7, 8, 1, 7, 0),
      (4, "c", 8, 9, 1, 8, 0),
      (-1, "<EOF>", 9, 9, 1, 9, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors NoViableAltAvoidance" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u209.grammar()
  let parsed = grammar.parse_default(
    "a.",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(s (e \"a\") (error \".\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(1)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(4, ".", 1, 2, 1, 1, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a.", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a.")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "token:a", "exit:e", "error:.", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "a", 0, 1, 1, 0, 0),
      (4, ".", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors SingleSetInsertion" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u210.grammar()
  let parsed = grammar.parse_default(
    "ad",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a\" \"d\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(1)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("ad", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "ad")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "token:d", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (4, "d", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors SingleSetInsertionConsumption" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(
            "" +
            observed_token_string(
              observed_context(event, "myset", []).stop_token.unwrap(),
              event.tokens,
            ) +
            "\n",
          )
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u211.grammar()
  let parsed = grammar.parse_default(
    "ad",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=1,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 2)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a\" (myset) \"d\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(1)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("ad", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "ad")
  assert_eq(printed.to_string(), "[@0,0:0='a',<3>,1:0]\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "enter:myset", "exit:myset", "token:d", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "a", 0, 1, 1, 0, 0),
      (4, "d", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors SingleTokenDeletion" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u212.grammar()
  let parsed = grammar.parse_default(
    "aab",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a\" (error \"a\") \"b\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(1)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(1, "a", 1, 2, 1, 1, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("aab", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "aab")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "error:a", "token:b", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (1, "a", 1, 2, 1, 1, 0),
      (2, "b", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors SingleTokenDeletionBeforeAlt" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u213.grammar()
  let parsed = grammar.parse_default(
    "ac",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(a (error \"a\") \"c\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(0)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(3, "a", 0, 1, 1, 0, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("ac", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "ac")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "error:a", "token:c", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "a", 0, 1, 1, 0, 0),
      (2, "c", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors SingleTokenDeletionBeforeLoop" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u214.grammar()
  let parsed = grammar.parse_default(
    "aabc",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a\" (error \"a\") \"b\" <EOF>)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(1)),
    (Some(1), Some(3)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(1, "a", 1, 2, 1, 1, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("aabc", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "aab<EOF>")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "error:a", "token:b", "token:<EOF>", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (1, "a", 1, 2, 1, 1, 0),
      (2, "b", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 4, 4, 1, 4, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [(1, 3)],
  )
}

///|
test "upstream ParserErrors SingleTokenDeletionBeforeLoop2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u215.grammar()
  let parsed = grammar.parse_default(
    "aabc",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a\" (error \"a\") \"b\" <EOF>)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(1)),
    (Some(1), Some(3)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(1, "a", 1, 2, 1, 1, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("aabc", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "aab<EOF>")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "error:a", "token:b", "token:<EOF>", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (1, "a", 1, 2, 1, 1, 0),
      (2, "b", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 4, 4, 1, 4, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [(1, 3)],
  )
}

///|
test "upstream ParserErrors SingleTokenDeletionBeforePredict" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u216.grammar()
  let parsed = grammar.parse_default(
    "caaab",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(a (error \"c\") \"a\" \"a\" \"a\" \"b\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(0)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(3, "c", 0, 1, 1, 0, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("caaab", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "caaab")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "error:c", "token:a", "token:a", "token:a", "token:b", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "c", 0, 1, 1, 0, 0),
      (1, "a", 1, 2, 1, 1, 0),
      (1, "a", 2, 3, 1, 2, 0),
      (1, "a", 3, 4, 1, 3, 0),
      (2, "b", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors SingleTokenDeletionConsumption" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(
            "" +
            observed_token_string(
              observed_context(event, "myset", []).stop_token.unwrap(),
              event.tokens,
            ) +
            "\n",
          )
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u217.grammar()
  let parsed = grammar.parse_default(
    "aabd",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=1,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 4)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(a \"a\" (myset (error \"a\") \"b\") \"d\")",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(1)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(3, "a", 1, 2, 1, 1, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("aabd", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "aabd")
  assert_eq(printed.to_string(), "[@2,2:2='b',<1>,1:2]\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "enter:myset", "error:a", "token:b", "exit:myset", "token:d",
    "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "a", 0, 1, 1, 0, 0),
      (3, "a", 1, 2, 1, 1, 0),
      (1, "b", 2, 3, 1, 2, 0),
      (4, "d", 3, 4, 1, 3, 0),
      (-1, "<EOF>", 4, 4, 1, 4, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors SingleTokenDeletionDuringLoop" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u218.grammar()
  let parsed = grammar.parse_default(
    "ababbc",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(a \"a\" \"b\" (error \"a\") \"b\" \"b\" \"c\")",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(2)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(1, "a", 2, 3, 1, 2, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("ababbc", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "ababbc")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "token:b", "error:a", "token:b", "token:b", "token:c",
    "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (2, "b", 1, 2, 1, 1, 0),
      (1, "a", 2, 3, 1, 2, 0),
      (2, "b", 3, 4, 1, 3, 0),
      (2, "b", 4, 5, 1, 4, 0),
      (3, "c", 5, 6, 1, 5, 0),
      (-1, "<EOF>", 6, 6, 1, 6, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors SingleTokenDeletionDuringLoop2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u219.grammar()
  let parsed = grammar.parse_default(
    "ababbc",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(a \"a\" \"b\" (error \"a\") \"b\" \"b\" \"c\")",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(2)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(1, "a", 2, 3, 1, 2, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("ababbc", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "ababbc")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "token:b", "error:a", "token:b", "token:b", "token:c",
    "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (2, "b", 1, 2, 1, 1, 0),
      (1, "a", 2, 3, 1, 2, 0),
      (2, "b", 3, 4, 1, 3, 0),
      (2, "b", 4, 5, 1, 4, 0),
      (4, "c", 5, 6, 1, 5, 0),
      (-1, "<EOF>", 6, 6, 1, 6, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors SingleTokenDeletionExpectingSet" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u220.grammar()
  let parsed = grammar.parse_default(
    "aab",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a\" (error \"a\") \"b\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(1)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(1, "a", 1, 2, 1, 1, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("aab", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "aab")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "error:a", "token:b", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (1, "a", 1, 2, 1, 1, 0),
      (2, "b", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors SingleTokenInsertion" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u221.grammar()
  let parsed = grammar.parse_default(
    "ac",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a\" (error \"<missing 'b'>\") \"c\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(1)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(2, "<missing 'b'>", -1, 0, 1, 1, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("ac", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "a<missing 'b'>c")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "error:<missing 'b'>", "token:c", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (3, "c", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors TokenMismatch" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u222.grammar()
  let parsed = grammar.parse_default(
    "aa",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a\" (error \"a\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(1)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(1, "a", 1, 2, 1, 1, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("aa", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "aa")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "error:a", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (1, "a", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors TokenMismatch2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u223.grammar()
  let parsed = grammar.parse_default(
    "( ~FORCE_ERROR~ ",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(stat \"(\" (error \"~FORCE_ERROR~\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(2)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(4, "~FORCE_ERROR~", 2, 15, 1, 2, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("( ~FORCE_ERROR~ ", lexer_action=(
    _,
    _,
  ) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "(~FORCE_ERROR~")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:stat", "token:(", "error:~FORCE_ERROR~", "exit:stat",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "(", 0, 1, 1, 0, 0),
      (4, "~FORCE_ERROR~", 2, 15, 1, 2, 0),
      (-1, "<EOF>", 16, 16, 1, 16, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserErrors TokenMismatch3" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u224.grammar()
  let parsed = grammar.parse_default(
    "",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(expression (value))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(0)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:expression", "enter:value", "exit:value", "exit:expression",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(-1, "<EOF>", 0, 0, 1, 0, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec AorAPlus" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u225.grammar()
  let parsed = grammar.parse_default(
    "a b c",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a\" \"b\" \"c\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a b c", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "abc")
  assert_eq(printed.to_string(), "abc\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "token:b", "token:c", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (1, "b", 2, 3, 1, 2, 0),
      (1, "c", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec AorAStar_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u226.grammar()
  let parsed = grammar.parse_default(
    "",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 0)])
  assert_eq(parsed.tree.to_sexpr(), "(a)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "")
  assert_eq(printed.to_string(), "\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), ["enter:a", "exit:a"])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(-1, "<EOF>", 0, 0, 1, 0, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec AorAStar_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u227.grammar()
  let parsed = grammar.parse_default(
    "a b c",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a\" \"b\" \"c\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a b c", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "abc")
  assert_eq(printed.to_string(), "abc\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "token:b", "token:c", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (1, "b", 2, 3, 1, 2, 0),
      (1, "c", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec AorB" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("alt 1" + "\n")
        1 => printed.write_string("alt 2" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u228.grammar()
  let parsed = grammar.parse_default(
    "34",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(1, 2)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"34\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("34", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "34")
  assert_eq(printed.to_string(), "alt 2\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:34", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(2, "34", 0, 2, 1, 0, 0), (-1, "<EOF>", 2, 2, 1, 2, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec AorBPlus" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        1 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u229.grammar()
  let parsed = grammar.parse_default(
    "a 34 c",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5), (1, 6)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a\" \"34\" \"c\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a 34 c", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "a34c")
  assert_eq(printed.to_string(), "a34c\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "token:34", "token:c", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (2, "34", 2, 4, 1, 2, 0),
      (1, "c", 5, 6, 1, 5, 0),
      (-1, "<EOF>", 6, 6, 1, 6, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec AorBStar_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        1 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u230.grammar()
  let parsed = grammar.parse_default(
    "",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(1, 0)])
  assert_eq(parsed.tree.to_sexpr(), "(a)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "")
  assert_eq(printed.to_string(), "\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), ["enter:a", "exit:a"])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(-1, "<EOF>", 0, 0, 1, 0, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec AorBStar_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        1 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u231.grammar()
  let parsed = grammar.parse_default(
    "a 34 c",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5), (1, 6)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a\" \"34\" \"c\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a 34 c", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "a34c")
  assert_eq(printed.to_string(), "a34c\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "token:34", "token:c", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (2, "34", 2, 4, 1, 2, 0),
      (1, "c", 5, 6, 1, 5, 0),
      (-1, "<EOF>", 6, 6, 1, 6, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec APlus" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u232.grammar()
  let parsed = grammar.parse_default(
    "a b c",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a\" \"b\" \"c\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a b c", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "abc")
  assert_eq(printed.to_string(), "abc\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "token:b", "token:c", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (1, "b", 2, 3, 1, 2, 0),
      (1, "c", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec AStar_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u233.grammar()
  let parsed = grammar.parse_default(
    "",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 0)])
  assert_eq(parsed.tree.to_sexpr(), "(a)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "")
  assert_eq(printed.to_string(), "\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), ["enter:a", "exit:a"])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(-1, "<EOF>", 0, 0, 1, 0, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec AStar_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u234.grammar()
  let parsed = grammar.parse_default(
    "a b c",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a\" \"b\" \"c\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a b c", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "abc")
  assert_eq(printed.to_string(), "abc\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "token:b", "token:c", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (1, "b", 2, 3, 1, 2, 0),
      (1, "c", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec Basic" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u235.grammar()
  let parsed = grammar.parse_default(
    "abc 34",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 6)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"abc\" \"34\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("abc 34", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "abc34")
  assert_eq(printed.to_string(), "abc34\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:abc", "token:34", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "abc", 0, 3, 1, 0, 0),
      (2, "34", 4, 6, 1, 4, 0),
      (-1, "<EOF>", 6, 6, 1, 6, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec BuildParseTree_FALSE" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u236.grammar()
  let parsed = grammar.parse_default(
    "A B",
    report_prediction=false,
    build_tree=false,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(r)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("A B", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=false),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "")
  assert_eq(printed.to_string(), "r\n")
  assert_true(parsed.context.children.is_empty())
  @debug.assert_eq(bound_listener_events(parsed.tree), ["enter:r", "exit:r"])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "A", 0, 1, 1, 0, 0),
      (2, "B", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec BuildParseTree_TRUE" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u237.grammar()
  let parsed = grammar.parse_default(
    "A B",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(r (a \"A\") (b \"B\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("A B", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "AB")
  assert_eq(printed.to_string(), "(r (a A) (b B))\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:r", "enter:a", "token:A", "exit:a", "enter:b", "token:B", "exit:b", "exit:r",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "A", 0, 1, 1, 0, 0),
      (2, "B", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec IfIfElseGreedyBinding1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u238.grammar()
  let parsed = grammar.parse_default(
    "if y if y x else x",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 18), (0, 18)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(start (statement (ifStatement \"if\" \"y\" (statement (ifStatement \"if\" \"y\" (statement \"x\") \"else\" (statement \"x\"))))))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("if y if y x else x", lexer_action=(
    _,
    _,
  ) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "ifyifyxelsex")
  assert_eq(printed.to_string(), "if y x else x\nif y if y x else x\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:start", "enter:statement", "enter:ifStatement", "token:if", "token:y",
    "enter:statement", "enter:ifStatement", "token:if", "token:y", "enter:statement",
    "token:x", "exit:statement", "token:else", "enter:statement", "token:x", "exit:statement",
    "exit:ifStatement", "exit:statement", "exit:ifStatement", "exit:statement", "exit:start",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "if", 0, 2, 1, 0, 0),
      (6, " ", 2, 3, 1, 2, 1),
      (3, "y", 3, 4, 1, 3, 0),
      (6, " ", 4, 5, 1, 4, 1),
      (2, "if", 5, 7, 1, 5, 0),
      (6, " ", 7, 8, 1, 7, 1),
      (3, "y", 8, 9, 1, 8, 0),
      (6, " ", 9, 10, 1, 9, 1),
      (1, "x", 10, 11, 1, 10, 0),
      (6, " ", 11, 12, 1, 11, 1),
      (4, "else", 12, 16, 1, 12, 0),
      (6, " ", 16, 17, 1, 16, 1),
      (1, "x", 17, 18, 1, 17, 0),
      (-1, "<EOF>", 18, 18, 1, 18, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec IfIfElseGreedyBinding2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u239.grammar()
  let parsed = grammar.parse_default(
    "if y if y x else x",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 18), (0, 18)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(start (statement (ifStatement \"if\" \"y\" (statement (ifStatement \"if\" \"y\" (statement \"x\") \"else\" (statement \"x\"))))))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("if y if y x else x", lexer_action=(
    _,
    _,
  ) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "ifyifyxelsex")
  assert_eq(printed.to_string(), "if y x else x\nif y if y x else x\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:start", "enter:statement", "enter:ifStatement", "token:if", "token:y",
    "enter:statement", "enter:ifStatement", "token:if", "token:y", "enter:statement",
    "token:x", "exit:statement", "token:else", "enter:statement", "token:x", "exit:statement",
    "exit:ifStatement", "exit:statement", "exit:ifStatement", "exit:statement", "exit:start",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "if", 0, 2, 1, 0, 0),
      (6, " ", 2, 3, 1, 2, 1),
      (3, "y", 3, 4, 1, 3, 0),
      (6, " ", 4, 5, 1, 4, 1),
      (2, "if", 5, 7, 1, 5, 0),
      (6, " ", 7, 8, 1, 7, 1),
      (3, "y", 8, 9, 1, 8, 0),
      (6, " ", 9, 10, 1, 9, 1),
      (1, "x", 10, 11, 1, 10, 0),
      (6, " ", 11, 12, 1, 11, 1),
      (4, "else", 12, 16, 1, 12, 0),
      (6, " ", 16, 17, 1, 16, 1),
      (1, "x", 17, 18, 1, 17, 0),
      (-1, "<EOF>", 18, 18, 1, 18, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec IfIfElseNonGreedyBinding1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u240.grammar()
  let parsed = grammar.parse_default(
    "if y if y x else x",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 12), (0, 18)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(start (statement (ifStatement \"if\" \"y\" (statement (ifStatement \"if\" \"y\" (statement \"x\"))) \"else\" (statement \"x\"))))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("if y if y x else x", lexer_action=(
    _,
    _,
  ) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]},{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "ifyifyxelsex")
  assert_eq(printed.to_string(), "if y x\nif y if y x else x\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:start", "enter:statement", "enter:ifStatement", "token:if", "token:y",
    "enter:statement", "enter:ifStatement", "token:if", "token:y", "enter:statement",
    "token:x", "exit:statement", "exit:ifStatement", "exit:statement", "token:else",
    "enter:statement", "token:x", "exit:statement", "exit:ifStatement", "exit:statement",
    "exit:start",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "if", 0, 2, 1, 0, 0),
      (6, " ", 2, 3, 1, 2, 1),
      (3, "y", 3, 4, 1, 3, 0),
      (6, " ", 4, 5, 1, 4, 1),
      (2, "if", 5, 7, 1, 5, 0),
      (6, " ", 7, 8, 1, 7, 1),
      (3, "y", 8, 9, 1, 8, 0),
      (6, " ", 9, 10, 1, 9, 1),
      (1, "x", 10, 11, 1, 10, 0),
      (6, " ", 11, 12, 1, 11, 1),
      (4, "else", 12, 16, 1, 12, 0),
      (6, " ", 16, 17, 1, 16, 1),
      (1, "x", 17, 18, 1, 17, 0),
      (-1, "<EOF>", 18, 18, 1, 18, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec IfIfElseNonGreedyBinding2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u241.grammar()
  let parsed = grammar.parse_default(
    "if y if y x else x",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 12), (0, 18)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(start (statement (ifStatement \"if\" \"y\" (statement (ifStatement \"if\" \"y\" (statement \"x\"))) \"else\" (statement \"x\"))))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("if y if y x else x", lexer_action=(
    _,
    _,
  ) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]},{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "ifyifyxelsex")
  assert_eq(printed.to_string(), "if y x\nif y if y x else x\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:start", "enter:statement", "enter:ifStatement", "token:if", "token:y",
    "enter:statement", "enter:ifStatement", "token:if", "token:y", "enter:statement",
    "token:x", "exit:statement", "exit:ifStatement", "exit:statement", "token:else",
    "enter:statement", "token:x", "exit:statement", "exit:ifStatement", "exit:statement",
    "exit:start",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "if", 0, 2, 1, 0, 0),
      (6, " ", 2, 3, 1, 2, 1),
      (3, "y", 3, 4, 1, 3, 0),
      (6, " ", 4, 5, 1, 4, 1),
      (2, "if", 5, 7, 1, 5, 0),
      (6, " ", 7, 8, 1, 7, 1),
      (3, "y", 8, 9, 1, 8, 0),
      (6, " ", 9, 10, 1, 9, 1),
      (1, "x", 10, 11, 1, 10, 0),
      (6, " ", 11, 12, 1, 11, 1),
      (4, "else", 12, 16, 1, 12, 0),
      (6, " ", 16, 17, 1, 16, 1),
      (1, "x", 17, 18, 1, 17, 0),
      (-1, "<EOF>", 18, 18, 1, 18, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec Keyword_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u242.grammar()
  let parsed = grammar.parse_default(
    "break;continue;return;",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 22)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(program (state \"break;\") (state \"continue;\") (state \"return;\") <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("break;continue;return;", lexer_action=(
    _,
    _,
  ) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "break;continue;return;<EOF>")
  assert_eq(printed.to_string(), "break;continue;return;\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:program", "enter:state", "token:break;", "exit:state", "enter:state",
    "token:continue;", "exit:state", "enter:state", "token:return;", "exit:state",
    "token:<EOF>", "exit:program",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "break;", 0, 6, 1, 0, 0),
      (2, "continue;", 6, 15, 1, 6, 0),
      (3, "return;", 15, 22, 1, 15, 0),
      (-1, "<EOF>", 22, 22, 1, 22, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec Keyword_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u243.grammar()
  let parsed = grammar.parse_default(
    "break;continue;return;",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 22)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(program (sempred \"break;\") (sempred \"continue;\") (sempred \"return;\") <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("break;continue;return;", lexer_action=(
    _,
    _,
  ) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "break;continue;return;<EOF>")
  assert_eq(printed.to_string(), "break;continue;return;\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:program", "enter:sempred", "token:break;", "exit:sempred", "enter:sempred",
    "token:continue;", "exit:sempred", "enter:sempred", "token:return;", "exit:sempred",
    "token:<EOF>", "exit:program",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "break;", 0, 6, 1, 0, 0),
      (2, "continue;", 6, 15, 1, 6, 0),
      (3, "return;", 15, 22, 1, 15, 0),
      (-1, "<EOF>", 22, 22, 1, 22, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec Keyword_3" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u244.grammar()
  let parsed = grammar.parse_default(
    "break;continue;return;",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 22)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(program (action \"break;\") (action \"continue;\") (action \"return;\") <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("break;continue;return;", lexer_action=(
    _,
    _,
  ) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "break;continue;return;<EOF>")
  assert_eq(printed.to_string(), "break;continue;return;\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:program", "enter:action", "token:break;", "exit:action", "enter:action",
    "token:continue;", "exit:action", "enter:action", "token:return;", "exit:action",
    "token:<EOF>", "exit:program",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "break;", 0, 6, 1, 0, 0),
      (2, "continue;", 6, 15, 1, 6, 0),
      (3, "return;", 15, 22, 1, 15, 0),
      (-1, "<EOF>", 22, 22, 1, 22, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec Keyword_4" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u245.grammar()
  let parsed = grammar.parse_default(
    "break;continue;return;",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 22)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(program (ruleIndexMap \"break;\") (ruleIndexMap \"continue;\") (ruleIndexMap \"return;\") <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("break;continue;return;", lexer_action=(
    _,
    _,
  ) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "break;continue;return;<EOF>")
  assert_eq(printed.to_string(), "break;continue;return;\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:program", "enter:ruleIndexMap", "token:break;", "exit:ruleIndexMap", "enter:ruleIndexMap",
    "token:continue;", "exit:ruleIndexMap", "enter:ruleIndexMap", "token:return;",
    "exit:ruleIndexMap", "token:<EOF>", "exit:program",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "break;", 0, 6, 1, 0, 0),
      (2, "continue;", 6, 15, 1, 6, 0),
      (3, "return;", 15, 22, 1, 15, 0),
      (-1, "<EOF>", 22, 22, 1, 22, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec Keyword_5" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u246.grammar()
  let parsed = grammar.parse_default(
    "break;continue;return;",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 22)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(program (addErrorListener \"break;\") (addErrorListener \"continue;\") (addErrorListener \"return;\") <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("break;continue;return;", lexer_action=(
    _,
    _,
  ) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "break;continue;return;<EOF>")
  assert_eq(printed.to_string(), "break;continue;return;\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:program", "enter:addErrorListener", "token:break;", "exit:addErrorListener",
    "enter:addErrorListener", "token:continue;", "exit:addErrorListener", "enter:addErrorListener",
    "token:return;", "exit:addErrorListener", "token:<EOF>", "exit:program",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "break;", 0, 6, 1, 0, 0),
      (2, "continue;", 6, 15, 1, 6, 0),
      (3, "return;", 15, 22, 1, 15, 0),
      (-1, "<EOF>", 22, 22, 1, 22, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec Keyword_6" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u247.grammar()
  let parsed = grammar.parse_default(
    "break;continue;return;",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 22)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(program (reset \"break;\") (reset \"continue;\") (reset \"return;\") <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("break;continue;return;", lexer_action=(
    _,
    _,
  ) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "break;continue;return;<EOF>")
  assert_eq(printed.to_string(), "break;continue;return;\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:program", "enter:reset", "token:break;", "exit:reset", "enter:reset",
    "token:continue;", "exit:reset", "enter:reset", "token:return;", "exit:reset",
    "token:<EOF>", "exit:program",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "break;", 0, 6, 1, 0, 0),
      (2, "continue;", 6, 15, 1, 6, 0),
      (3, "return;", 15, 22, 1, 15, 0),
      (-1, "<EOF>", 22, 22, 1, 22, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec LabelAliasingAcrossLabeledAlternatives" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_label_text(event, [14, 17]) + "\n")
        1 => printed.write_string(observed_label_text(event, [14, 17]) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u248.grammar()
  let parsed = grammar.parse_default(
    "xy",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1), (1, 2)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(start (a (subrule \"x\")) (a \"y\") <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("xy", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "xy<EOF>")
  assert_eq(printed.to_string(), "x\ny\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:start", "enter:a", "enter:subrule", "token:x", "exit:subrule", "exit:a",
    "enter:a", "token:y", "exit:a", "token:<EOF>", "exit:start",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "x", 0, 1, 1, 0, 0),
      (1, "y", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec Labels" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u249.grammar()
  let parsed = grammar.parse_default(
    "abc 34;",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(a (b \"abc\" \"34\") \";\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("abc 34;", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "abc34;")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "enter:b", "token:abc", "token:34", "exit:b", "token:;", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "abc", 0, 3, 1, 0, 0),
      (3, "34", 4, 6, 1, 4, 0),
      (1, ";", 6, 7, 1, 6, 0),
      (-1, "<EOF>", 7, 7, 1, 7, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec ListLabelForClosureContext" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u250.grammar()
  let parsed = grammar.parse_default(
    "a",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=2,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(expression \"a\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "a")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:expression", "token:a", "exit:expression",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(5, "a", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec ListLabelsOnRuleRefStartOfAlt" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u251.grammar()
  let parsed = grammar.parse_default(
    "a and b",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 7), (0, 7)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(expression (expression \"a\") \"and\" (expression \"b\"))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a and b", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "aandb")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:expression", "enter:expression", "token:a", "exit:expression", "token:and",
    "enter:expression", "token:b", "exit:expression", "exit:expression",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (4, "a", 0, 1, 1, 0, 0),
      (1, "and", 2, 5, 1, 2, 0),
      (4, "b", 6, 7, 1, 6, 0),
      (-1, "<EOF>", 7, 7, 1, 7, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec ListLabelsOnSet" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u252.grammar()
  let parsed = grammar.parse_default(
    "abc 34;",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(a (b \"abc\" \"34\") \";\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("abc 34;", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "abc34;")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "enter:b", "token:abc", "token:34", "exit:b", "token:;", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "abc", 0, 3, 1, 0, 0),
      (3, "34", 4, 6, 1, 4, 0),
      (1, ";", 6, 7, 1, 6, 0),
      (-1, "<EOF>", 7, 7, 1, 7, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec LL1OptionalBlock_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        1 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u253.grammar()
  let parsed = grammar.parse_default(
    "",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(1, 0)])
  assert_eq(parsed.tree.to_sexpr(), "(a)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "")
  assert_eq(printed.to_string(), "\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), ["enter:a", "exit:a"])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(-1, "<EOF>", 0, 0, 1, 0, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec LL1OptionalBlock_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        1 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u254.grammar()
  let parsed = grammar.parse_default(
    "a",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(1, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "a")
  assert_eq(printed.to_string(), "a\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "a", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec MultipleEOFHandling" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u255.grammar()
  let parsed = grammar.parse_default(
    "x",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(prog \"x\" <EOF> <EOF>)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "x<EOF><EOF>")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:prog", "token:x", "token:<EOF>", "token:<EOF>", "exit:prog",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "x", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec OpenDeviceStatement_Case1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u256.grammar()
  let parsed = grammar.parse_default(
    "OPEN DEVICE DEVICE",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=1,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 18)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(statement \"OPEN\" \"DEVICE\" \"DEVICE\")",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("OPEN DEVICE DEVICE", lexer_action=(
    _,
    _,
  ) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "OPENDEVICEDEVICE")
  assert_eq(printed.to_string(), "OPEN DEVICE DEVICE\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:statement", "token:OPEN", "token:DEVICE", "token:DEVICE", "exit:statement",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "OPEN", 0, 4, 1, 0, 0),
      (7, " ", 4, 5, 1, 4, 1),
      (3, "DEVICE", 5, 11, 1, 5, 0),
      (7, " ", 11, 12, 1, 11, 1),
      (3, "DEVICE", 12, 18, 1, 12, 0),
      (-1, "<EOF>", 18, 18, 1, 18, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec OpenDeviceStatement_Case2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u257.grammar()
  let parsed = grammar.parse_default(
    "OPEN DEVICE DEVICE",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=1,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 18)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(statement \"OPEN\" \"DEVICE\" \"DEVICE\")",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("OPEN DEVICE DEVICE", lexer_action=(
    _,
    _,
  ) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "OPENDEVICEDEVICE")
  assert_eq(printed.to_string(), "OPEN DEVICE DEVICE\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:statement", "token:OPEN", "token:DEVICE", "token:DEVICE", "exit:statement",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "OPEN", 0, 4, 1, 0, 0),
      (7, " ", 4, 5, 1, 4, 1),
      (3, "DEVICE", 5, 11, 1, 5, 0),
      (7, " ", 11, 12, 1, 11, 1),
      (3, "DEVICE", 12, 18, 1, 12, 0),
      (-1, "<EOF>", 18, 18, 1, 18, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec OpenDeviceStatement_Case3" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u258.grammar()
  let parsed = grammar.parse_default(
    "OPEN DEVICE DEVICE.",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=1,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 18)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(statement \"OPEN\" \"DEVICE\" \"DEVICE\")",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, 1)
  assert_eq(parsed.next_token.text, ".")
  let lexed = grammar.tokenize_recovering("OPEN DEVICE DEVICE.", lexer_action=(
    _,
    _,
  ) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "OPENDEVICEDEVICE")
  assert_eq(printed.to_string(), "OPEN DEVICE DEVICE\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:statement", "token:OPEN", "token:DEVICE", "token:DEVICE", "exit:statement",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "OPEN", 0, 4, 1, 0, 0),
      (7, " ", 4, 5, 1, 4, 1),
      (3, "DEVICE", 5, 11, 1, 5, 0),
      (7, " ", 11, 12, 1, 11, 1),
      (3, "DEVICE", 12, 18, 1, 12, 0),
      (1, ".", 18, 19, 1, 18, 0),
      (-1, "<EOF>", 19, 19, 1, 19, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec Optional_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u259.grammar()
  let parsed = grammar.parse_default(
    "x",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(stat \"x\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "x")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:stat", "token:x", "exit:stat",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "x", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec Optional_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u260.grammar()
  let parsed = grammar.parse_default(
    "if x",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(stat (ifstat \"if\" (stat \"x\")))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("if x", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "ifx")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:stat", "enter:ifstat", "token:if", "enter:stat", "token:x", "exit:stat",
    "exit:ifstat", "exit:stat",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "if", 0, 2, 1, 0, 0),
      (1, "x", 3, 4, 1, 3, 0),
      (-1, "<EOF>", 4, 4, 1, 4, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec Optional_3" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u261.grammar()
  let parsed = grammar.parse_default(
    "if x else x",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(stat (ifstat \"if\" (stat \"x\") \"else\" (stat \"x\")))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("if x else x", lexer_action=(_, _) => {
    ()
  })
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "ifxelsex")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:stat", "enter:ifstat", "token:if", "enter:stat", "token:x", "exit:stat",
    "token:else", "enter:stat", "token:x", "exit:stat", "exit:ifstat", "exit:stat",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "if", 0, 2, 1, 0, 0),
      (1, "x", 3, 4, 1, 3, 0),
      (3, "else", 5, 9, 1, 5, 0),
      (1, "x", 10, 11, 1, 10, 0),
      (-1, "<EOF>", 11, 11, 1, 11, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec Optional_4" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u262.grammar()
  let parsed = grammar.parse_default(
    "if if x else x",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(stat (ifstat \"if\" (stat (ifstat \"if\" (stat \"x\") \"else\" (stat \"x\")))))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("if if x else x", lexer_action=(_, _) => {
    ()
  })
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "ififxelsex")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:stat", "enter:ifstat", "token:if", "enter:stat", "enter:ifstat", "token:if",
    "enter:stat", "token:x", "exit:stat", "token:else", "enter:stat", "token:x",
    "exit:stat", "exit:ifstat", "exit:stat", "exit:ifstat", "exit:stat",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "if", 0, 2, 1, 0, 0),
      (2, "if", 3, 5, 1, 3, 0),
      (1, "x", 6, 7, 1, 6, 0),
      (3, "else", 8, 12, 1, 8, 0),
      (1, "x", 13, 14, 1, 13, 0),
      (-1, "<EOF>", 14, 14, 1, 14, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec OrderingPredicates" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u263.grammar()
  let parsed = grammar.parse_default(
    "POINT AT X",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=1,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(expr (expr \"POINT\") \"AT\" \"X\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("POINT AT X", lexer_action=(_, _) => {
    ()
  })
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "POINTATX")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:expr", "enter:expr", "token:POINT", "exit:expr", "token:AT", "token:X",
    "exit:expr",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (6, "POINT", 0, 5, 1, 0, 0),
      (3, "AT", 6, 8, 1, 6, 0),
      (4, "X", 9, 10, 1, 9, 0),
      (-1, "<EOF>", 10, 10, 1, 10, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec ParserProperty" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => true
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("valid" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u264.grammar()
  let parsed = grammar.parse_default(
    "abc",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"abc\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("abc", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "abc")
  assert_eq(printed.to_string(), "valid\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:abc", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "abc", 0, 3, 1, 0, 0), (-1, "<EOF>", 3, 3, 1, 3, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec PredicatedIfIfElse" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => event.lookahead(1).kind != 2
        _ => false
      }
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u265.grammar()
  let parsed = grammar.parse_default(
    "if x if x a else b",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (stmt (ifStmt \"if\" \"x\" (stmt (ifStmt \"if\" \"x\" (stmt \"a\") \"else\" (stmt \"b\"))))) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("if x if x a else b", lexer_action=(
    _,
    _,
  ) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}]}]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "ifxifxaelseb<EOF>")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:stmt", "enter:ifStmt", "token:if", "token:x", "enter:stmt",
    "enter:ifStmt", "token:if", "token:x", "enter:stmt", "token:a", "exit:stmt",
    "token:else", "enter:stmt", "token:b", "exit:stmt", "exit:ifStmt", "exit:stmt",
    "exit:ifStmt", "exit:stmt", "token:<EOF>", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "if", 0, 2, 1, 0, 0),
      (3, "x", 3, 4, 1, 3, 0),
      (1, "if", 5, 7, 1, 5, 0),
      (3, "x", 8, 9, 1, 8, 0),
      (3, "a", 10, 11, 1, 10, 0),
      (2, "else", 12, 16, 1, 12, 0),
      (3, "b", 17, 18, 1, 17, 0),
      (-1, "<EOF>", 18, 18, 1, 18, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec PredictionIssue334" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => event.control.unwrap().bail = true
        1 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u266.grammar()
  let parsed = grammar.parse_default(
    "a",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 0), (1, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(file_ (item \"a\") <EOF>)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a<EOF>")
  assert_eq(printed.to_string(), "(file_ (item a) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:file_", "enter:item", "token:a", "exit:item", "token:<EOF>", "exit:file_",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(2, "a", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec PredictionMode_LL" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u267.grammar()
  let parsed = grammar.parse_default(
    "X Y",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(r (a \"X\") (b \"Y\") <EOF>)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("X Y", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "XY<EOF>")
  assert_eq(printed.to_string(), "(r (a X) (b Y) <EOF>)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:r", "enter:a", "token:X", "exit:a", "enter:b", "token:Y", "exit:b", "token:<EOF>",
    "exit:r",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "X", 0, 1, 1, 0, 0),
      (2, "Y", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec PredictionMode_SLL" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u268.grammar()
  let parsed = grammar.parse_default(
    "X Y",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.SLL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(r (a \"X\" \"Y\") (b (error \"<missing 'Y'>\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(3)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(2, "<missing 'Y'>", -1, 0, 1, 2, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("X Y", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "XY<missing 'Y'><EOF>")
  assert_eq(printed.to_string(), "XY\n")
  assert_eq(parsed.prediction.full_context_fallbacks, 0)
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:r", "enter:a", "token:X", "token:Y", "exit:a", "enter:b", "error:<missing 'Y'>",
    "exit:b", "token:<EOF>", "exit:r",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "X", 0, 1, 1, 0, 0),
      (2, "Y", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec ReferenceToATN_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u269.grammar()
  let parsed = grammar.parse_default(
    "",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 0)])
  assert_eq(parsed.tree.to_sexpr(), "(a)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "")
  assert_eq(printed.to_string(), "\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), ["enter:a", "exit:a"])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(-1, "<EOF>", 0, 0, 1, 0, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec ReferenceToATN_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u270.grammar()
  let parsed = grammar.parse_default(
    "a 34 c",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 6)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a\" \"34\" \"c\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a 34 c", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "a34c")
  assert_eq(printed.to_string(), "a34c\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "token:34", "token:c", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (2, "34", 2, 4, 1, 2, 0),
      (1, "c", 5, 6, 1, 5, 0),
      (-1, "<EOF>", 6, 6, 1, 6, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec ReservedWordsEscaping" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    enter: (rule, frame) => {
      if rule == 1 && !frame.values.contains("return") {
        frame.values["return"] = Json::number(0.0)
      }
      if rule == 2 && !frame.values.contains("else") {
        frame.values["else"] = Json::number(0.0)
      }
      if rule == 2 && !frame.values.contains("return") {
        frame.values["return"] = Json::number(0.0)
      }
      frame
    },
    wrap: (rule, previous) => {
      let values : Map[String, Json] = Map([])
      if rule == 2 {
        if previous.values.get("else") is Some(value) {
          values["else"] = value
        }
      }
      if rule == 1 && !values.contains("return") {
        values["return"] = Json::number(0.0)
      }
      if rule == 2 && !values.contains("else") {
        values["else"] = Json::number(0.0)
      }
      if rule == 2 && !values.contains("return") {
        values["return"] = Json::number(0.0)
      }
      { values, shared: previous.shared.copy(), children: [previous], }
    },
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => 0 == 0
        1 => 1 == 1
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_text(event, event.context, true))
        1 => event.frame.values["return"] = Json::number((0).to_double())
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u271.grammar()
  let parsed = grammar.parse_default(
    "for for break break for if if for continue",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(1, 42), (0, 42)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(root (continue (for \"for \") (for \"for \")) (continue \"break \" \"break \" (for \"for \")) (continue \"if \" \"if \") (continue (continue (for \"for \")) \"continue\"))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering(
    "for for break break for if if for continue",
    lexer_action=(_, _) => (),
  )
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{\"return\":0},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]},{\"values\":{\"return\":0},\"children\":[{\"values\":{},\"children\":[]}]},{\"values\":{\"return\":0},\"children\":[]},{\"values\":{\"return\":0},\"children\":[{\"values\":{\"return\":0},\"children\":[{\"values\":{},\"children\":[]}]}]}]}",
    ),
  )
  assert_eq(
    parsed.context.get_text(),
    "for for break break for if if for continue",
  )
  assert_eq(printed.to_string(), "for for break break for if if for continue")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:root", "enter:continue", "enter:for", "token:for ", "exit:for", "enter:for",
    "token:for ", "exit:for", "exit:continue", "enter:continue", "token:break ",
    "token:break ", "enter:for", "token:for ", "exit:for", "exit:continue", "enter:continue",
    "token:if ", "token:if ", "exit:continue", "enter:continue", "enter:continue",
    "enter:for", "token:for ", "exit:for", "exit:continue", "token:continue", "exit:continue",
    "exit:root",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "for ", 0, 4, 1, 0, 0),
      (1, "for ", 4, 8, 1, 4, 0),
      (2, "break ", 8, 14, 1, 8, 0),
      (2, "break ", 14, 20, 1, 14, 0),
      (1, "for ", 20, 24, 1, 20, 0),
      (3, "if ", 24, 27, 1, 24, 0),
      (3, "if ", 27, 30, 1, 27, 0),
      (1, "for ", 30, 34, 1, 30, 0),
      (4, "continue", 34, 42, 1, 34, 0),
      (-1, "<EOF>", 42, 42, 1, 42, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec TokenOffset" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u272.grammar()
  let parsed = grammar.parse_default(
    "12 34 56 66",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 11)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"12\" \"34\" \"56\" \"66\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("12 34 56 66", lexer_action=(_, _) => {
    ()
  })
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "12345666")
  assert_eq(printed.to_string(), "12345666\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:12", "token:34", "token:56", "token:66", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (12, "12", 0, 2, 1, 0, 0),
      (34, "34", 3, 5, 1, 3, 0),
      (56, "56", 6, 8, 1, 6, 0),
      (66, "66", 9, 11, 1, 9, 0),
      (-1, "<EOF>", 11, 11, 1, 11, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec uStartingCharDoesNotCauseIllegalUnicodeEscape" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u273.grammar()
  let parsed = grammar.parse_default(
    "u",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(u \"u\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("u", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "u")
  assert_eq(printed.to_string(), "u\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:u", "token:u", "exit:u",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "u", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParserExec Wildcard" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string(observed_text(event, event.context, true) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u274.grammar()
  let parsed = grammar.parse_default(
    "x=10; abc;;;; y=99;",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 6), (0, 19)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(a (assign \"x\" \"=\" \"10\" \";\") \"abc\" \";\" \";\" \";\" \";\" (assign \"y\" \"=\" \"99\" \";\") <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x=10; abc;;;; y=99;", lexer_action=(
    _,
    _,
  ) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "x=10;abc;;;;y=99;<EOF>")
  assert_eq(printed.to_string(), "x=10;\ny=99;\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "enter:assign", "token:x", "token:=", "token:10", "token:;", "exit:assign",
    "token:abc", "token:;", "token:;", "token:;", "token:;", "enter:assign", "token:y",
    "token:=", "token:99", "token:;", "exit:assign", "token:<EOF>", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "x", 0, 1, 1, 0, 0),
      (1, "=", 1, 2, 1, 1, 0),
      (4, "10", 2, 4, 1, 2, 0),
      (2, ";", 4, 5, 1, 4, 0),
      (3, "abc", 6, 9, 1, 6, 0),
      (2, ";", 9, 10, 1, 9, 0),
      (2, ";", 10, 11, 1, 10, 0),
      (2, ";", 11, 12, 1, 11, 0),
      (2, ";", 12, 13, 1, 12, 0),
      (3, "y", 14, 15, 1, 14, 0),
      (1, "=", 15, 16, 1, 15, 0),
      (4, "99", 16, 18, 1, 16, 0),
      (2, ";", 18, 19, 1, 18, 0),
      (-1, "<EOF>", 19, 19, 1, 19, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParseTrees AltNum" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        1 => event.control.unwrap().build_tree = true
        2 =>
          printed.write_string(
            observed_tree(observed_context(event, "r", [6]), alternatives=[
              ("s", 1, [6]),
              ("a", 1, [8]),
              ("a", 2, [9]),
              ("a", 3, [10, 11, 12]),
              ("b", 1, [16, 17]),
              ("b", 2, [18]),
            ]) +
            "\n",
          )
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u275.grammar()
  let parsed = grammar.parse_default(
    "xyz",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(1, 0), (2, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"x\" (b \"y\") \"z\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("xyz", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "xyz")
  assert_eq(printed.to_string(), "(a:3 x (b:2 y) z)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:x", "enter:b", "token:y", "exit:b", "token:z", "exit:a",
    "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "x", 0, 1, 1, 0, 0),
      (6, "y", 1, 2, 1, 1, 0),
      (4, "z", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParseTrees ExtraToken" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => event.control.unwrap().build_tree = true
        1 =>
          printed.write_string(
            observed_tree(observed_context(event, "r", [4])) + "\n",
          )
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u276.grammar()
  let parsed = grammar.parse_default(
    "xzy",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 0), (1, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"x\" (error \"z\") \"y\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(1)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(3, "z", 1, 2, 1, 1, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("xzy", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "xzy")
  assert_eq(printed.to_string(), "(a x z y)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:x", "error:z", "token:y", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "x", 0, 1, 1, 0, 0),
      (3, "z", 1, 2, 1, 1, 0),
      (2, "y", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParseTrees ExtraTokensAndAltLabels" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => event.control.unwrap().build_tree = true
        1 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u277.grammar()
  let parsed = grammar.parse_default(
    "${ ? a ?}",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 0), (1, 9)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s \"${\" (v (error \"?\") \"a\") (error \"?\") \"}\")",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(3)),
    (Some(1), Some(7)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(6, "?", 3, 4, 1, 3, 0), (6, "?", 7, 8, 1, 7, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("${ ? a ?}", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "${?a?}")
  assert_eq(printed.to_string(), "(s ${ (v ? a) ? })\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "token:${", "enter:v", "error:?", "token:a", "exit:v", "error:?",
    "token:}", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "${", 0, 2, 1, 0, 0),
      (5, " ", 2, 3, 1, 2, 1),
      (6, "?", 3, 4, 1, 3, 0),
      (5, " ", 4, 5, 1, 4, 1),
      (3, "a", 5, 6, 1, 5, 0),
      (5, " ", 6, 7, 1, 6, 1),
      (6, "?", 7, 8, 1, 7, 0),
      (2, "}", 8, 9, 1, 8, 0),
      (-1, "<EOF>", 9, 9, 1, 9, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParseTrees NoViableAlt" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => event.control.unwrap().build_tree = true
        1 =>
          printed.write_string(
            observed_tree(observed_context(event, "r", [4])) + "\n",
          )
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u278.grammar()
  let parsed = grammar.parse_default(
    "z",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 0), (1, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a (error \"z\")))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(0)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(3, "z", 0, 1, 1, 0, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("z", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "z")
  assert_eq(printed.to_string(), "(a z)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "error:z", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(3, "z", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParseTrees RuleRef" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => event.control.unwrap().build_tree = true
        1 =>
          printed.write_string(
            observed_tree(observed_context(event, "r", [6])) + "\n",
          )
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u279.grammar()
  let parsed = grammar.parse_default(
    "yx",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 0), (1, 2)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a (b \"y\") \"x\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("yx", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "yx")
  assert_eq(printed.to_string(), "(a (b y) x)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "enter:b", "token:y", "exit:b", "token:x", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "y", 0, 1, 1, 0, 0),
      (1, "x", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParseTrees Sync" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => event.control.unwrap().build_tree = true
        1 =>
          printed.write_string(
            observed_tree(observed_context(event, "r", [4])) + "\n",
          )
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u280.grammar()
  let parsed = grammar.parse_default(
    "xzyy!",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 0), (1, 5)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (a \"x\" (error \"z\") \"y\" \"y\" \"!\"))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(1)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(4, "z", 1, 2, 1, 1, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("xzyy!", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "xzyy!")
  assert_eq(printed.to_string(), "(a x z y y !)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:x", "error:z", "token:y", "token:y", "token:!",
    "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "x", 0, 1, 1, 0, 0),
      (4, "z", 1, 2, 1, 1, 0),
      (2, "y", 2, 3, 1, 2, 0),
      (2, "y", 3, 4, 1, 3, 0),
      (3, "!", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParseTrees Token2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => event.control.unwrap().build_tree = true
        1 =>
          printed.write_string(
            observed_tree(observed_context(event, "r", [4])) + "\n",
          )
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u281.grammar()
  let parsed = grammar.parse_default(
    "xy",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 0), (1, 2)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"x\" \"y\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("xy", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "xy")
  assert_eq(printed.to_string(), "(a x y)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:x", "token:y", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "x", 0, 1, 1, 0, 0),
      (2, "y", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParseTrees TokenAndRuleContextString" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string("[" + event.rule_stack.join(", ") + "]" + "\n")
        1 => event.control.unwrap().build_tree = true
        2 =>
          printed.write_string(
            observed_tree(observed_context(event, "r", [4])) + "\n",
          )
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u282.grammar()
  let parsed = grammar.parse_default(
    "x",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(1, 0), (0, 1), (2, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"x\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "x")
  assert_eq(printed.to_string(), "[a, s]\n(a x)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:x", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "x", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParseTrees TwoAltLoop" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => event.control.unwrap().build_tree = true
        1 =>
          printed.write_string(
            observed_tree(observed_context(event, "r", [4])) + "\n",
          )
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u283.grammar()
  let parsed = grammar.parse_default(
    "xyyxyxz",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 0), (1, 7)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (a \"x\" \"y\" \"y\" \"x\" \"y\" \"x\" \"z\"))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("xyyxyxz", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "xyyxyxz")
  assert_eq(printed.to_string(), "(a x y y x y x z)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:x", "token:y", "token:y", "token:x", "token:y",
    "token:x", "token:z", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "x", 0, 1, 1, 0, 0),
      (2, "y", 1, 2, 1, 1, 0),
      (2, "y", 2, 3, 1, 2, 0),
      (1, "x", 3, 4, 1, 3, 0),
      (2, "y", 4, 5, 1, 4, 0),
      (1, "x", 5, 6, 1, 5, 0),
      (3, "z", 6, 7, 1, 6, 0),
      (-1, "<EOF>", 7, 7, 1, 7, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream ParseTrees TwoAlts" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => event.control.unwrap().build_tree = true
        1 =>
          printed.write_string(
            observed_tree(observed_context(event, "r", [4])) + "\n",
          )
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u284.grammar()
  let parsed = grammar.parse_default(
    "y",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 0), (1, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"y\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("y", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "y")
  assert_eq(printed.to_string(), "(a y)\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:y", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(2, "y", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalLexer DisableRule" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let predicate : @runtime.LexerContextPredicate = event => {
    match event.predicate {
      0 => false
      1 => true
      _ => false
    }
  }
  let cursor = @runtime.deserialize(@u285.lexer_data()).lexer_cursor(
    "enum abc",
    lexer_context_predicate=predicate,
    lexer_action=lexer_observer,
    recover=true,
  )
  cursor.enable_dfa_trace()
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  printed.write_string(cursor.dump_dfa())
  assert_eq(
    printed.to_string(),
    "[@0,0:3='enum',<2>,1:0]\n[@1,5:7='abc',<3>,1:5]\n[@2,8:7='<EOF>',<-1>,1:8]\ns0-' '->:s5=>4\ns0-'a'->:s6=>3\ns0-'e'->:s1=>3\n:s1=>3-'n'->:s2=>3\n:s2=>3-'u'->:s3=>3\n:s6=>3-'b'->:s6=>3\n:s6=>3-'c'->:s6=>3\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "enum", 0, 4, 1, 0, 0),
      (3, "abc", 5, 8, 1, 5, 0),
      (-1, "<EOF>", 8, 8, 1, 8, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalLexer EnumNotID" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let predicate : @runtime.LexerContextPredicate = event => {
    match event.predicate {
      0 => event.text == "enum"
      _ => false
    }
  }
  let cursor = @runtime.deserialize(@u286.lexer_data()).lexer_cursor(
    "enum abc enum",
    lexer_context_predicate=predicate,
    lexer_action=lexer_observer,
    recover=true,
  )
  cursor.enable_dfa_trace()
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  printed.write_string(cursor.dump_dfa())
  assert_eq(
    printed.to_string(),
    "[@0,0:3='enum',<1>,1:0]\n[@1,5:7='abc',<2>,1:5]\n[@2,9:12='enum',<1>,1:9]\n[@3,13:12='<EOF>',<-1>,1:13]\ns0-' '->:s3=>3\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "enum", 0, 4, 1, 0, 0),
      (2, "abc", 5, 8, 1, 5, 0),
      (1, "enum", 9, 13, 1, 9, 0),
      (-1, "<EOF>", 13, 13, 1, 13, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalLexer IDnotEnum" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let predicate : @runtime.LexerContextPredicate = event => {
    match event.predicate {
      0 => false
      _ => false
    }
  }
  let cursor = @runtime.deserialize(@u287.lexer_data()).lexer_cursor(
    "enum abc enum",
    lexer_context_predicate=predicate,
    lexer_action=lexer_observer,
    recover=true,
  )
  cursor.enable_dfa_trace()
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  printed.write_string(cursor.dump_dfa())
  assert_eq(
    printed.to_string(),
    "[@0,0:3='enum',<2>,1:0]\n[@1,5:7='abc',<2>,1:5]\n[@2,9:12='enum',<2>,1:9]\n[@3,13:12='<EOF>',<-1>,1:13]\ns0-' '->:s2=>3\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "enum", 0, 4, 1, 0, 0),
      (2, "abc", 5, 8, 1, 5, 0),
      (2, "enum", 9, 13, 1, 9, 0),
      (-1, "<EOF>", 13, 13, 1, 13, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalLexer IDvsEnum" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let predicate : @runtime.LexerContextPredicate = event => {
    match event.predicate {
      0 => false
      _ => false
    }
  }
  let cursor = @runtime.deserialize(@u288.lexer_data()).lexer_cursor(
    "enum abc enum",
    lexer_context_predicate=predicate,
    lexer_action=lexer_observer,
    recover=true,
  )
  cursor.enable_dfa_trace()
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  printed.write_string(cursor.dump_dfa())
  assert_eq(
    printed.to_string(),
    "[@0,0:3='enum',<2>,1:0]\n[@1,5:7='abc',<2>,1:5]\n[@2,9:12='enum',<2>,1:9]\n[@3,13:12='<EOF>',<-1>,1:13]\ns0-' '->:s5=>3\ns0-'a'->:s4=>2\ns0-'e'->:s1=>2\n:s1=>2-'n'->:s2=>2\n:s2=>2-'u'->:s3=>2\n:s4=>2-'b'->:s4=>2\n:s4=>2-'c'->:s4=>2\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "enum", 0, 4, 1, 0, 0),
      (2, "abc", 5, 8, 1, 5, 0),
      (2, "enum", 9, 13, 1, 9, 0),
      (-1, "<EOF>", 13, 13, 1, 13, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalLexer Indent" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      (1, 0) => printed.write_string("INDENT" + "\n")
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let predicate : @runtime.LexerContextPredicate = event => {
    match event.predicate {
      0 => event.token_column == 0
      _ => false
    }
  }
  let cursor = @runtime.deserialize(@u289.lexer_data()).lexer_cursor(
    "abc\n  def  \n",
    lexer_context_predicate=predicate,
    lexer_action=lexer_observer,
    recover=true,
  )
  cursor.enable_dfa_trace()
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  printed.write_string(cursor.dump_dfa())
  assert_eq(
    printed.to_string(),
    "INDENT\n[@0,0:2='abc',<1>,1:0]\n[@1,3:3='\\n',<3>,1:3]\n[@2,4:5='  ',<2>,2:0]\n[@3,6:8='def',<1>,2:2]\n[@4,9:10='  ',<4>,2:5]\n[@5,11:11='\\n',<3>,2:7]\n[@6,12:11='<EOF>',<-1>,3:0]\ns0-'\n'->:s2=>3\ns0-'a'->:s1=>1\ns0-'d'->:s1=>1\n:s1=>1-'b'->:s1=>1\n:s1=>1-'c'->:s1=>1\n:s1=>1-'e'->:s1=>1\n:s1=>1-'f'->:s1=>1\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "abc", 0, 3, 1, 0, 0),
      (3, "\n", 3, 4, 1, 3, 0),
      (2, "  ", 4, 6, 2, 0, 0),
      (1, "def", 6, 9, 2, 2, 0),
      (4, "  ", 9, 11, 2, 5, 0),
      (3, "\n", 11, 12, 2, 7, 0),
      (-1, "<EOF>", 12, 12, 3, 0, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalLexer LexerInputPositionSensitivePredicates" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      (0, 0) =>
        printed.write_string(
          event.text.unwrap_or(
            String::from_array(
              source.to_array()[event.token_start:event.offset],
            ),
          ) +
          "\n",
        )
      (1, 1) =>
        printed.write_string(
          event.text.unwrap_or(
            String::from_array(
              source.to_array()[event.token_start:event.offset],
            ),
          ) +
          "\n",
        )
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let predicate : @runtime.LexerContextPredicate = event => {
    match event.predicate {
      0 => event.column < 2
      1 => event.column >= 2
      _ => false
    }
  }
  let cursor = @runtime.deserialize(@u290.lexer_data()).lexer_cursor(
    "a cde\nabcde\n",
    lexer_context_predicate=predicate,
    lexer_action=lexer_observer,
    recover=true,
  )
  cursor.enable_dfa_trace()
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  printed.write_string(cursor.dump_dfa())
  assert_eq(
    printed.to_string(),
    "a\ncde\nab\ncde\n[@0,0:0='a',<1>,1:0]\n[@1,2:4='cde',<2>,1:2]\n[@2,6:7='ab',<1>,2:0]\n[@3,8:10='cde',<2>,2:2]\n[@4,12:11='<EOF>',<-1>,3:0]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (2, "cde", 2, 5, 1, 2, 0),
      (1, "ab", 6, 8, 2, 0, 0),
      (2, "cde", 8, 11, 2, 2, 0),
      (-1, "<EOF>", 12, 12, 3, 0, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalLexer PredicatedKeywords" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      (0, 0) => printed.write_string("enum!" + "\n")
      (1, 1) =>
        printed.write_string(
          "ID " +
          event.text.unwrap_or(
            String::from_array(
              source.to_array()[event.token_start:event.offset],
            ),
          ) +
          "\n",
        )
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let predicate : @runtime.LexerContextPredicate = event => {
    match event.predicate {
      0 => event.text == "enum"
      _ => false
    }
  }
  let cursor = @runtime.deserialize(@u291.lexer_data()).lexer_cursor(
    "enum enu a",
    lexer_context_predicate=predicate,
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "enum!\nID enu\nID a\n[@0,0:3='enum',<1>,1:0]\n[@1,5:7='enu',<2>,1:5]\n[@2,9:9='a',<2>,1:9]\n[@3,10:9='<EOF>',<-1>,1:10]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "enum", 0, 4, 1, 0, 0),
      (2, "enu", 5, 8, 1, 5, 0),
      (2, "a", 9, 10, 1, 9, 0),
      (-1, "<EOF>", 10, 10, 1, 10, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalLexer RuleSempredFunction" {
  let printed = StringBuilder()
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let predicate : @runtime.LexerContextPredicate = event => {
    match event.predicate {
      0 => true
      _ => false
    }
  }
  let cursor = @runtime.deserialize(@u292.lexer_data()).lexer_cursor(
    "aaa",
    lexer_context_predicate=predicate,
    lexer_action=lexer_observer,
    recover=true,
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  let lexed : @runtime.LexResult = { tokens, errors: cursor.diagnostics(), }
  for token in lexed.tokens {
    printed.write_string(observed_token_string(token, lexed.tokens) + "\n")
  }
  assert_eq(
    printed.to_string(),
    "[@0,0:0='a',<1>,1:0]\n[@1,1:1='a',<1>,1:1]\n[@2,2:2='a',<1>,1:2]\n[@3,3:2='<EOF>',<-1>,1:3]\n",
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (1, "a", 1, 2, 1, 1, 0),
      (1, "a", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser ActionHidesPreds" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => bound_int(event.frame.shared, "i") == 1
        1 => bound_int(event.frame.shared, "i") == 2
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 => event.frame.shared["i"] = Json::number((1).to_double())
        1 => printed.write_string("alt 1" + "\n")
        2 => event.frame.shared["i"] = Json::number((2).to_double())
        3 => printed.write_string("alt 2" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u293.grammar()
  let parsed = grammar.parse_default(
    "x x y",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([("i", Json::number((0).to_double()))]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 0), (1, 2), (0, 2), (1, 4), (0, 4), (1, 5)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"x\") (a \"x\") (a \"y\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x x y", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "xxy")
  assert_eq(printed.to_string(), "alt 1\nalt 1\nalt 1\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:x", "exit:a", "enter:a", "token:x", "exit:a", "enter:a",
    "token:y", "exit:a", "exit:s",
  ])
  assert_eq(parsed.frame.unwrap().shared.get("i"), Some(@json.parse("1")))
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "x", 0, 1, 1, 0, 0),
      (1, "x", 2, 3, 1, 2, 0),
      (1, "y", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser ActionsHidePredsInGlobalFOLLOW" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => observed_pred(printed, true)
        1 => observed_pred(printed, false)
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        1 => printed.write_string("parse" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u294.grammar()
  let parsed = grammar.parse_default(
    "a!",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1), (1, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e \"a\") \"!\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a!", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a!")
  assert_eq(printed.to_string(), "eval=true\nparse\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "token:a", "exit:e", "token:!", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "a", 0, 1, 1, 0, 0),
      (1, "!", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser AtomWithClosureInTranslatedLRRule" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    enter: (rule, frame) => {
      if rule == 1 && !frame.values.contains("_p") {
        frame.values["_p"] = Json::number(0.0)
      }
      frame
    },
    wrap: (rule, previous) => {
      let values : Map[String, Json] = Map([])
      if rule == 1 {
        if previous.values.get("_p") is Some(value) {
          values["_p"] = value
        }
      }
      if rule == 1 && !values.contains("_p") {
        values["_p"] = Json::number(0.0)
      }
      { values, shared: previous.shared.copy(), children: [previous], }
    },
    arguments: (event, _) => {
      match event.site {
        4 => Map([("_p", Json::number((0).to_double()))])
        17 => Map([("_p", Json::number((4).to_double()))])
        _ => Map([])
      }
    },
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => 3 >= bound_int(event.frame.values, "_p")
        _ => false
      }
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u295.grammar()
  let parsed = grammar.parse_default(
    "a+b+a",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(start (e \"a\" \"+\" (e \"b\") \"+\" (e \"a\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a+b+a", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{\"_p\":0},\"children\":[{\"values\":{\"_p\":4},\"children\":[]},{\"values\":{\"_p\":4},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a+b+a<EOF>")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:start", "enter:e", "token:a", "token:+", "enter:e", "token:b", "exit:e",
    "token:+", "enter:e", "token:a", "exit:e", "exit:e", "token:<EOF>", "exit:start",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (3, "+", 1, 2, 1, 1, 0),
      (2, "b", 2, 3, 1, 2, 0),
      (3, "+", 3, 4, 1, 3, 0),
      (1, "a", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser DepedentPredsInGlobalFOLLOW" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    enter: (rule, frame) => {
      if rule == 1 && !frame.values.contains("i") {
        frame.values["i"] = Json::number(0.0)
      }
      if rule == 2 && !frame.values.contains("i") {
        frame.values["i"] = Json::number(0.0)
      }
      frame
    },
    wrap: (rule, previous) => {
      let values : Map[String, Json] = Map([])
      if rule == 1 {
        if previous.values.get("i") is Some(value) {
          values["i"] = value
        }
      }
      if rule == 2 {
        if previous.values.get("i") is Some(value) {
          values["i"] = value
        }
      }
      if rule == 1 && !values.contains("i") {
        values["i"] = Json::number(0.0)
      }
      if rule == 2 && !values.contains("i") {
        values["i"] = Json::number(0.0)
      }
      { values, shared: previous.shared.copy(), children: [previous], }
    },
    arguments: (event, _) => {
      match event.site {
        8 => Map([("i", Json::number((99).to_double()))])
        _ => Map([])
      }
    },
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => observed_pred(printed, bound_int(event.frame.values, "i") == 99)
        1 => observed_pred(printed, bound_int(event.frame.values, "i") == 99)
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("parse" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u296.grammar()
  let parsed = grammar.parse_default(
    "a!",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a (e \"a\") \"!\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a!", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{\"i\":99},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a!")
  assert_eq(printed.to_string(), "eval=true\nparse\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "enter:e", "token:a", "exit:e", "token:!", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "a", 0, 1, 1, 0, 0),
      (1, "!", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser DependentPredNotInOuterCtxShouldBeIgnored" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    enter: (rule, frame) => {
      if rule == 1 && !frame.values.contains("i") {
        frame.values["i"] = Json::number(0.0)
      }
      if rule == 2 && !frame.values.contains("i") {
        frame.values["i"] = Json::number(0.0)
      }
      frame
    },
    wrap: (rule, previous) => {
      let values : Map[String, Json] = Map([])
      if rule == 1 {
        if previous.values.get("i") is Some(value) {
          values["i"] = value
        }
      }
      if rule == 2 {
        if previous.values.get("i") is Some(value) {
          values["i"] = value
        }
      }
      if rule == 1 && !values.contains("i") {
        values["i"] = Json::number(0.0)
      }
      if rule == 2 && !values.contains("i") {
        values["i"] = Json::number(0.0)
      }
      { values, shared: previous.shared.copy(), children: [previous], }
    },
    arguments: (event, _) => {
      match event.site {
        6 => Map([("i", Json::number((2).to_double()))])
        9 => Map([("i", Json::number((2).to_double()))])
        14 =>
          Map([
            ("i", Json::number(bound_int(event.frame.values, "i").to_double())),
          ])
        _ => Map([])
      }
    },
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => bound_int(event.frame.values, "i") == 1
        1 => bound_int(event.frame.values, "i") == 2
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("alt 1" + "\n")
        1 => printed.write_string("alt 2" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u297.grammar()
  let parsed = grammar.parse_default(
    "a;",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(1, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (b (a \"a\")) \";\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a;", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{\"i\":2},\"children\":[{\"values\":{\"i\":2},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a;")
  assert_eq(printed.to_string(), "alt 2\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:b", "enter:a", "token:a", "exit:a", "exit:b", "token:;", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "a", 0, 1, 1, 0, 0),
      (1, ";", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser DisabledAlternative" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => false
        _ => false
      }
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u298.grammar()
  let parsed = grammar.parse_default(
    "hello",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(cppCompilationUnit (content (anything \"h\")) (content (anything \"e\")) (content (anything \"l\")) (content (anything \"l\")) (content (anything \"o\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("hello", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "hello<EOF>")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:cppCompilationUnit", "enter:content", "enter:anything", "token:h", "exit:anything",
    "exit:content", "enter:content", "enter:anything", "token:e", "exit:anything",
    "exit:content", "enter:content", "enter:anything", "token:l", "exit:anything",
    "exit:content", "enter:content", "enter:anything", "token:l", "exit:anything",
    "exit:content", "enter:content", "enter:anything", "token:o", "exit:anything",
    "exit:content", "token:<EOF>", "exit:cppCompilationUnit",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "h", 0, 1, 1, 0, 0),
      (1, "e", 1, 2, 1, 1, 0),
      (1, "l", 2, 3, 1, 2, 0),
      (1, "l", 3, 4, 1, 3, 0),
      (1, "o", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser IndependentPredNotPassedOuterCtxToAvoidCastException" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => false
        1 => true
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("alt 1" + "\n")
        1 => printed.write_string("alt 2" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u299.grammar()
  let parsed = grammar.parse_default(
    "a;",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(1, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (b (a \"a\")) \";\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a;", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a;")
  assert_eq(printed.to_string(), "alt 2\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:b", "enter:a", "token:a", "exit:a", "exit:b", "token:;", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "a", 0, 1, 1, 0, 0),
      (1, ";", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser NoTruePredsThrowsNoViableAlt" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => false
        1 => false
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("alt 1" + "\n")
        1 => printed.write_string("alt 2" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u300.grammar()
  let parsed = grammar.parse_default(
    "y 3 x 4",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (a) (a (error \"y\") (error \"3\") (error \"x\") (error \"4\")))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(0)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [
      (1, "y", 0, 1, 1, 0, 0),
      (2, "3", 2, 3, 1, 2, 0),
      (1, "x", 4, 5, 1, 4, 0),
      (2, "4", 6, 7, 1, 6, 0),
    ],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("y 3 x 4", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "y3x4")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "exit:a", "enter:a", "error:y", "error:3", "error:x", "error:4",
    "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "y", 0, 1, 1, 0, 0),
      (2, "3", 2, 3, 1, 2, 0),
      (1, "x", 4, 5, 1, 4, 0),
      (2, "4", 6, 7, 1, 6, 0),
      (-1, "<EOF>", 7, 7, 1, 7, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser Order" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => true
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        1 => printed.write_string("alt 1" + "\n")
        2 => printed.write_string("alt 2" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u301.grammar()
  let parsed = grammar.parse_default(
    "x y",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(1, 2), (0, 2), (1, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"x\") (a \"y\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x y", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "xy")
  assert_eq(printed.to_string(), "alt 1\nalt 1\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:x", "exit:a", "enter:a", "token:y", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "x", 0, 1, 1, 0, 0),
      (1, "y", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser PredFromAltTestedInLoopBack_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => event.lookahead(2).kind != 2
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u302.grammar()
  let parsed = grammar.parse_default(
    "s\n\n\nx\n",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 6)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(file_ (para (paraContent \"s\") \"\\n\" \"\\n\") (para (paraContent \"\\n\" \"x\" \"\\n\")) <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(5), Some(0)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("s\n\n\nx\n", lexer_action=(_, _) => {
    ()
  })
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "s\n\n\nx\n<EOF>")
  assert_eq(
    printed.to_string(),
    "(file_ (para (paraContent s) \\n \\n) (para (paraContent \\n x \\n)) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:file_", "enter:para", "enter:paraContent", "token:s", "exit:paraContent",
    "token:\n", "token:\n", "exit:para", "enter:para", "enter:paraContent", "token:\n",
    "token:x", "token:\n", "exit:paraContent", "exit:para", "token:<EOF>", "exit:file_",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "s", 0, 1, 1, 0, 0),
      (2, "\n", 1, 2, 1, 1, 0),
      (2, "\n", 2, 3, 2, 0, 0),
      (2, "\n", 3, 4, 3, 0, 0),
      (3, "x", 4, 5, 4, 0, 0),
      (2, "\n", 5, 6, 4, 1, 0),
      (-1, "<EOF>", 6, 6, 5, 0, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser PredFromAltTestedInLoopBack_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => event.lookahead(2).kind != 2
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_tree(event.context) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u303.grammar()
  let parsed = grammar.parse_default(
    "s\n\n\nx\n\n",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 7)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(file_ (para (paraContent \"s\") \"\\n\" \"\\n\") (para (paraContent \"\\n\" \"x\") \"\\n\" \"\\n\") <EOF>)",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("s\n\n\nx\n\n", lexer_action=(_, _) => {
    ()
  })
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]},{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "s\n\n\nx\n\n<EOF>")
  assert_eq(
    printed.to_string(),
    "(file_ (para (paraContent s) \\n \\n) (para (paraContent \\n x) \\n \\n) <EOF>)\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:file_", "enter:para", "enter:paraContent", "token:s", "exit:paraContent",
    "token:\n", "token:\n", "exit:para", "enter:para", "enter:paraContent", "token:\n",
    "token:x", "exit:paraContent", "token:\n", "token:\n", "exit:para", "token:<EOF>",
    "exit:file_",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "s", 0, 1, 1, 0, 0),
      (2, "\n", 1, 2, 1, 1, 0),
      (2, "\n", 2, 3, 2, 0, 0),
      (2, "\n", 3, 4, 3, 0, 0),
      (3, "x", 4, 5, 4, 0, 0),
      (2, "\n", 5, 6, 4, 1, 0),
      (2, "\n", 6, 7, 5, 0, 0),
      (-1, "<EOF>", 7, 7, 6, 0, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser PredicateDependentOnArg" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    enter: (rule, frame) => {
      if rule == 1 && !frame.values.contains("i") {
        frame.values["i"] = Json::number(0.0)
      }
      frame
    },
    wrap: (rule, previous) => {
      let values : Map[String, Json] = Map([])
      if rule == 1 {
        if previous.values.get("i") is Some(value) {
          values["i"] = value
        }
      }
      if rule == 1 && !values.contains("i") {
        values["i"] = Json::number(0.0)
      }
      { values, shared: previous.shared.copy(), children: [previous], }
    },
    arguments: (event, _) => {
      match event.site {
        4 => Map([("i", Json::number((2).to_double()))])
        5 => Map([("i", Json::number((1).to_double()))])
        _ => Map([])
      }
    },
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => bound_int(event.frame.values, "i") == 1
        1 => bound_int(event.frame.values, "i") == 2
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("alt 1" + "\n")
        1 => printed.write_string("alt 2" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u304.grammar()
  let parsed = grammar.parse_default(
    "a b",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([("i", Json::number((0).to_double()))]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(1, 2), (0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"a\") (a \"b\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a b", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{\"i\":2},\"children\":[]},{\"values\":{\"i\":1},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "ab")
  assert_eq(printed.to_string(), "alt 2\nalt 1\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:a", "exit:a", "enter:a", "token:b", "exit:a", "exit:s",
  ])
  assert_eq(parsed.frame.unwrap().shared.get("i"), Some(@json.parse("0")))
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (1, "b", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser PredicateDependentOnArg2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    enter: (rule, frame) => {
      if rule == 1 && !frame.values.contains("i") {
        frame.values["i"] = Json::number(0.0)
      }
      frame
    },
    wrap: (rule, previous) => {
      let values : Map[String, Json] = Map([])
      if rule == 1 {
        if previous.values.get("i") is Some(value) {
          values["i"] = value
        }
      }
      if rule == 1 && !values.contains("i") {
        values["i"] = Json::number(0.0)
      }
      { values, shared: previous.shared.copy(), children: [previous], }
    },
    arguments: (event, _) => {
      match event.site {
        4 => Map([("i", Json::number((2).to_double()))])
        5 => Map([("i", Json::number((1).to_double()))])
        _ => Map([])
      }
    },
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => bound_int(event.frame.values, "i") == 1
        1 => bound_int(event.frame.values, "i") == 2
        _ => false
      }
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u305.grammar()
  let parsed = grammar.parse_default(
    "a b",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([("i", Json::number((0).to_double()))]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"a\") (a \"b\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a b", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{\"i\":2},\"children\":[]},{\"values\":{\"i\":1},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "ab")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:a", "exit:a", "enter:a", "token:b", "exit:a", "exit:s",
  ])
  assert_eq(parsed.frame.unwrap().shared.get("i"), Some(@json.parse("0")))
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (1, "b", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser PredsInGlobalFOLLOW" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => observed_pred(printed, true)
        1 => observed_pred(printed, false)
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("parse" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u306.grammar()
  let parsed = grammar.parse_default(
    "a!",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(s (e \"a\") \"!\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a!", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "a!")
  assert_eq(printed.to_string(), "eval=true\nparse\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:e", "token:a", "exit:e", "token:!", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "a", 0, 1, 1, 0, 0),
      (1, "!", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser PredTestedEvenWhenUnAmbig_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => !bound_bool(event.frame.shared, "enumKeyword")
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string("ID " + observed_token(event, 2, []).text + "\n")
        1 => printed.write_string("enum" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u307.grammar()
  let parsed = grammar.parse_default(
    "abc",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([("enumKeyword", Json::boolean(true))]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(primary \"abc\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("abc", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "abc")
  assert_eq(printed.to_string(), "ID abc\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:primary", "token:abc", "exit:primary",
  ])
  assert_eq(
    parsed.frame.unwrap().shared.get("enumKeyword"),
    Some(@json.parse("true")),
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(2, "abc", 0, 3, 1, 0, 0), (-1, "<EOF>", 3, 3, 1, 3, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser PredTestedEvenWhenUnAmbig_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => !bound_bool(event.frame.shared, "enumKeyword")
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          printed.write_string("ID " + observed_token(event, 2, []).text + "\n")
        1 => printed.write_string("enum" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u308.grammar()
  let parsed = grammar.parse_default(
    "enum",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([("enumKeyword", Json::boolean(true))]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(primary (error \"enum\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(0)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(1, "enum", 0, 4, 1, 0, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("enum", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "enum")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:primary", "error:enum", "exit:primary",
  ])
  assert_eq(
    parsed.frame.unwrap().shared.get("enumKeyword"),
    Some(@json.parse("true")),
  )
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "enum", 0, 4, 1, 0, 0), (-1, "<EOF>", 4, 4, 1, 4, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser RewindBeforePredEval" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => event.lookahead(1).text == "x"
        1 => event.lookahead(1).text == "y"
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("alt 1" + "\n")
        1 => printed.write_string("alt 2" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u309.grammar()
  let parsed = grammar.parse_default(
    "y 3 x 4",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(1, 4), (0, 7)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"y\" \"3\") (a \"x\" \"4\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("y 3 x 4", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "y3x4")
  assert_eq(printed.to_string(), "alt 2\nalt 1\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:y", "token:3", "exit:a", "enter:a", "token:x", "token:4",
    "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "y", 0, 1, 1, 0, 0),
      (2, "3", 2, 3, 1, 2, 0),
      (1, "x", 4, 5, 1, 4, 0),
      (2, "4", 6, 7, 1, 6, 0),
      (-1, "<EOF>", 7, 7, 1, 7, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser Simple" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => false
        1 => true
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("alt 1" + "\n")
        1 => printed.write_string("alt 2" + "\n")
        2 => printed.write_string("alt 3" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u310.grammar()
  let parsed = grammar.parse_default(
    "x y 3",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(1, 2), (1, 4), (2, 5)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"x\") (a \"y\") (a \"3\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x y 3", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "xy3")
  assert_eq(printed.to_string(), "alt 2\nalt 2\nalt 3\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:x", "exit:a", "enter:a", "token:y", "exit:a", "enter:a",
    "token:3", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "x", 0, 1, 1, 0, 0),
      (1, "y", 2, 3, 1, 2, 0),
      (2, "3", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser SimpleValidate" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => false
        1 => true
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("alt 1" + "\n")
        1 => printed.write_string("alt 2" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u311.grammar()
  let parsed = grammar.parse_default(
    "x",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(s (a (error \"x\")))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(0)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(1, "x", 0, 1, 1, 0, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "x")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "error:x", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "x", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser SimpleValidate2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => false
        1 => true
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("alt 1" + "\n")
        1 => printed.write_string("alt 2" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u312.grammar()
  let parsed = grammar.parse_default(
    "3 4 x",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(1, 2), (1, 4)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"3\") (a \"4\") (a (error \"x\")))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(4)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(1, "x", 4, 5, 1, 4, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("3 4 x", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "34x")
  assert_eq(printed.to_string(), "alt 2\nalt 2\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:3", "exit:a", "enter:a", "token:4", "exit:a", "enter:a",
    "error:x", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "3", 0, 1, 1, 0, 0),
      (2, "4", 2, 3, 1, 2, 0),
      (1, "x", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser ToLeft" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => false
        1 => true
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("alt 1" + "\n")
        1 => printed.write_string("alt 2" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u313.grammar()
  let parsed = grammar.parse_default(
    "x x y",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(1, 2), (1, 4), (1, 5)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"x\") (a \"x\") (a \"y\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x x y", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "xxy")
  assert_eq(printed.to_string(), "alt 2\nalt 2\nalt 2\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:x", "exit:a", "enter:a", "token:x", "exit:a", "enter:a",
    "token:y", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "x", 0, 1, 1, 0, 0),
      (1, "x", 2, 3, 1, 2, 0),
      (1, "y", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser ToLeftWithVaryingPredicate" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => bound_int(event.frame.shared, "i") % 2 == 0
        1 => bound_int(event.frame.shared, "i") % 2 != 0
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 => {
          event.frame.shared["i"] = Json::number(
            (bound_int(event.frame.shared, "i") + 1).to_double(),
          )
          printed.write_string("i=")
          printed.write_string(
            bound_int(event.frame.shared, "i").to_string() + "\n",
          )
        }
        1 => printed.write_string("alt 1" + "\n")
        2 => printed.write_string("alt 2" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u314.grammar()
  let parsed = grammar.parse_default(
    "x x y",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([("i", Json::number((0).to_double()))]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 0), (2, 2), (0, 2), (1, 4), (0, 4), (2, 5)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"x\") (a \"x\") (a \"y\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x x y", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "xxy")
  assert_eq(printed.to_string(), "i=1\nalt 2\ni=2\nalt 1\ni=3\nalt 2\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:x", "exit:a", "enter:a", "token:x", "exit:a", "enter:a",
    "token:y", "exit:a", "exit:s",
  ])
  assert_eq(parsed.frame.unwrap().shared.get("i"), Some(@json.parse("3")))
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "x", 0, 1, 1, 0, 0),
      (1, "x", 2, 3, 1, 2, 0),
      (1, "y", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser TwoUnpredicatedAlts" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => false
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          event.control.unwrap().prediction_mode = @runtime.LL_EXACT_AMBIG_DETECTION
        1 => printed.write_string("alt 1" + "\n")
        2 => printed.write_string("alt 2" + "\n")
        3 => printed.write_string("alt 3" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u315.grammar()
  let parsed = grammar.parse_default(
    "x; y",
    report_prediction=true,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 0), (1, 1), (1, 4)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"x\") \";\" (a \"y\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(0)),
    (Some(1), Some(0)),
    (Some(1), Some(3)),
    (Some(1), Some(3)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x; y", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "x;y")
  assert_eq(printed.to_string(), "alt 1\nalt 1\n")
  let expected_prediction : Json = [
    {
      "kind": "attempting_full_context",
      "decision": 0,
      "start": 0,
      "stop": 0,
      "exact": false,
      "alternatives": [1, 2],
      "prediction": 0,
    },
    {
      "kind": "ambiguity",
      "decision": 0,
      "start": 0,
      "stop": 0,
      "exact": true,
      "alternatives": [1, 2],
      "prediction": 0,
    },
    {
      "kind": "attempting_full_context",
      "decision": 0,
      "start": 3,
      "stop": 3,
      "exact": false,
      "alternatives": [1, 2],
      "prediction": 0,
    },
    {
      "kind": "ambiguity",
      "decision": 0,
      "start": 3,
      "stop": 3,
      "exact": true,
      "alternatives": [1, 2],
      "prediction": 0,
    },
  ]
  @debug.assert_eq(
    Json::array(parsed.prediction_events.map(event => event.to_json())),
    expected_prediction,
  )
  assert_eq(
    parsed.diagnostics
    .filter(d => d.code.has_prefix("prediction_"))
    .map(d => {
      "line " +
      d.line.unwrap().to_string() +
      ":" +
      d.column.unwrap().to_string() +
      " " +
      d.message +
      "\n"
    })
    .join(""),
    "line 1:0 reportAttemptingFullContext d=0 (a), input='x'\nline 1:0 reportAmbiguity d=0 (a): ambigAlts={1, 2}, input='x'\nline 1:3 reportAttemptingFullContext d=0 (a), input='y'\nline 1:3 reportAmbiguity d=0 (a): ambigAlts={1, 2}, input='y'\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:x", "exit:a", "token:;", "enter:a", "token:y", "exit:a",
    "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "x", 0, 1, 1, 0, 0),
      (1, ";", 1, 2, 1, 1, 0),
      (2, "y", 3, 4, 1, 3, 0),
      (-1, "<EOF>", 4, 4, 1, 4, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser TwoUnpredicatedAltsAndOneOrthogonalAlt" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => false
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 =>
          event.control.unwrap().prediction_mode = @runtime.LL_EXACT_AMBIG_DETECTION
        1 => printed.write_string("alt 1" + "\n")
        2 => printed.write_string("alt 2" + "\n")
        3 => printed.write_string("alt 3" + "\n")
        4 => printed.write_string("alt 4" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u316.grammar()
  let parsed = grammar.parse_default(
    "34; x; y",
    report_prediction=true,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 0), (1, 2), (2, 5), (2, 8)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (a \"34\") \";\" (a \"x\") \";\" (a \"y\"))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(4)),
    (Some(1), Some(4)),
    (Some(1), Some(7)),
    (Some(1), Some(7)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("34; x; y", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "34;x;y")
  assert_eq(printed.to_string(), "alt 1\nalt 2\nalt 2\n")
  let expected_prediction : Json = [
    {
      "kind": "attempting_full_context",
      "decision": 0,
      "start": 4,
      "stop": 4,
      "exact": false,
      "alternatives": [2, 3],
      "prediction": 0,
    },
    {
      "kind": "ambiguity",
      "decision": 0,
      "start": 4,
      "stop": 4,
      "exact": true,
      "alternatives": [2, 3],
      "prediction": 0,
    },
    {
      "kind": "attempting_full_context",
      "decision": 0,
      "start": 7,
      "stop": 7,
      "exact": false,
      "alternatives": [2, 3],
      "prediction": 0,
    },
    {
      "kind": "ambiguity",
      "decision": 0,
      "start": 7,
      "stop": 7,
      "exact": true,
      "alternatives": [2, 3],
      "prediction": 0,
    },
  ]
  @debug.assert_eq(
    Json::array(parsed.prediction_events.map(event => event.to_json())),
    expected_prediction,
  )
  assert_eq(
    parsed.diagnostics
    .filter(d => d.code.has_prefix("prediction_"))
    .map(d => {
      "line " +
      d.line.unwrap().to_string() +
      ":" +
      d.column.unwrap().to_string() +
      " " +
      d.message +
      "\n"
    })
    .join(""),
    "line 1:4 reportAttemptingFullContext d=0 (a), input='x'\nline 1:4 reportAmbiguity d=0 (a): ambigAlts={2, 3}, input='x'\nline 1:7 reportAttemptingFullContext d=0 (a), input='y'\nline 1:7 reportAmbiguity d=0 (a): ambigAlts={2, 3}, input='y'\n",
  )
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:34", "exit:a", "token:;", "enter:a", "token:x",
    "exit:a", "token:;", "enter:a", "token:y", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "34", 0, 2, 1, 0, 0),
      (1, ";", 2, 3, 1, 2, 0),
      (2, "x", 4, 5, 1, 4, 0),
      (1, ";", 5, 6, 1, 5, 0),
      (2, "y", 7, 8, 1, 7, 0),
      (-1, "<EOF>", 8, 8, 1, 8, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser UnpredicatedPathsInAlt" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => false
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("alt 1" + "\n")
        1 => printed.write_string("alt 2" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u317.grammar()
  let parsed = grammar.parse_default(
    "x 4",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(s (a \"x\" \"4\"))")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x 4", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "x4")
  assert_eq(printed.to_string(), "alt 1\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "token:x", "token:4", "exit:a", "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "x", 0, 1, 1, 0, 0),
      (2, "4", 2, 3, 1, 2, 0),
      (-1, "<EOF>", 3, 3, 1, 3, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream SemPredEvalParser ValidateInDFA" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, index) => {
      ignore(event)
      match index {
        0 => false
        1 => true
        _ => false
      }
    },
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string("alt 1" + "\n")
        1 => printed.write_string("alt 2" + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u318.grammar()
  let parsed = grammar.parse_default(
    "x ; y",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(s (a (error \"x\")) \";\" (a (error \"y\")))",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(0)),
    (Some(1), Some(4)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [(2, "x", 0, 1, 1, 0, 0), (2, "y", 4, 5, 1, 4, 0)],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x ; y", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse(
      "{\"values\":{},\"children\":[{\"values\":{},\"children\":[]},{\"values\":{},\"children\":[]}]}",
    ),
  )
  assert_eq(parsed.context.get_text(), "x;y")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:s", "enter:a", "error:x", "exit:a", "token:;", "enter:a", "error:y", "exit:a",
    "exit:s",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "x", 0, 1, 1, 0, 0),
      (1, ";", 2, 3, 1, 2, 0),
      (2, "y", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets CharSetLiteral" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_token(event, 1, []).text + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u319.grammar()
  let parsed = grammar.parse_default(
    "A a B b",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 2), (0, 4), (0, 6), (0, 7)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"A\" \"a\" \"B\" \"b\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("A a B b", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "AaBb")
  assert_eq(printed.to_string(), "A\na\nB\nb\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:A", "token:a", "token:B", "token:b", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "A", 0, 1, 1, 0, 0),
      (1, "a", 2, 3, 1, 2, 0),
      (1, "B", 4, 5, 1, 4, 0),
      (1, "b", 6, 7, 1, 6, 0),
      (-1, "<EOF>", 7, 7, 1, 7, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets ComplementSet" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = { ..@runtime.RuleSemantics::new(), }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u320.grammar()
  let parsed = grammar.parse_default(
    "a",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [])
  assert_eq(parsed.tree.to_sexpr(), "(parse)")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(0)),
    (Some(1), Some(1)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "")
  assert_eq(printed.to_string(), "")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:parse", "exit:parse",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [(1, 0)],
  )
}

///|
test "upstream Sets LexerOptionalSet" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_input(event) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u321.grammar()
  let parsed = grammar.parse_default(
    "ac",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 2)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"ac\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("ac", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "ac")
  assert_eq(printed.to_string(), "ac\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:ac", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "ac", 0, 2, 1, 0, 0), (-1, "<EOF>", 2, 2, 1, 2, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets LexerPlusSet" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_input(event) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u322.grammar()
  let parsed = grammar.parse_default(
    "abaac",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"abaac\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("abaac", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "abaac")
  assert_eq(printed.to_string(), "abaac\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:abaac", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "abaac", 0, 5, 1, 0, 0), (-1, "<EOF>", 5, 5, 1, 5, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets LexerStarSet" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_input(event) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u323.grammar()
  let parsed = grammar.parse_default(
    "abaac",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"abaac\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("abaac", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "abaac")
  assert_eq(printed.to_string(), "abaac\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:abaac", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "abaac", 0, 5, 1, 0, 0), (-1, "<EOF>", 5, 5, 1, 5, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets NotChar" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_token(event, 1, []).text + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u324.grammar()
  let parsed = grammar.parse_default(
    "x",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"x\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "x")
  assert_eq(printed.to_string(), "x\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:x", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "x", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets NotCharSet" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_token(event, 1, []).text + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u325.grammar()
  let parsed = grammar.parse_default(
    "x",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"x\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "x")
  assert_eq(printed.to_string(), "x\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:x", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "x", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets NotCharSetWithRuleRef3" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_token(event, 1, []).text + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u326.grammar()
  let parsed = grammar.parse_default(
    "x",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"x\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "x")
  assert_eq(printed.to_string(), "x\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:x", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "x", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets OptionalLexerSingleElement" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_input(event) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u327.grammar()
  let parsed = grammar.parse_default(
    "bc",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 2)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"bc\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("bc", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "bc")
  assert_eq(printed.to_string(), "bc\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:bc", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "bc", 0, 2, 1, 0, 0), (-1, "<EOF>", 2, 2, 1, 2, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets OptionalSet" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_input(event) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u328.grammar()
  let parsed = grammar.parse_default(
    "ac",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 2)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a\" \"c\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("ac", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "ac")
  assert_eq(printed.to_string(), "ac\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "token:c", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (3, "c", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets OptionalSingleElement" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_input(event) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u329.grammar()
  let parsed = grammar.parse_default(
    "bc",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 2)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"b\" \"c\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("bc", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "bc")
  assert_eq(printed.to_string(), "bc\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:b", "token:c", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "b", 0, 1, 1, 0, 0),
      (1, "c", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets ParserNotSet" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_label_text(event, [2]) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u330.grammar()
  let parsed = grammar.parse_default(
    "zz",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 2)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"z\" \"z\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("zz", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "zz")
  assert_eq(printed.to_string(), "z\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:z", "token:z", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (3, "z", 0, 1, 1, 0, 0),
      (3, "z", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets ParserNotToken" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_input(event) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u331.grammar()
  let parsed = grammar.parse_default(
    "zz",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 2)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"z\" \"z\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("zz", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "zz")
  assert_eq(printed.to_string(), "zz\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:z", "token:z", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "z", 0, 1, 1, 0, 0),
      (2, "z", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets ParserNotTokenWithLabel" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_label_text(event, [2]) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u332.grammar()
  let parsed = grammar.parse_default(
    "zz",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 2)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"z\" \"z\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("zz", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "zz")
  assert_eq(printed.to_string(), "z\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:z", "token:z", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "z", 0, 1, 1, 0, 0),
      (2, "z", 1, 2, 1, 1, 0),
      (-1, "<EOF>", 2, 2, 1, 2, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets ParserSet" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_label_text(event, [2]) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u333.grammar()
  let parsed = grammar.parse_default(
    "x",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"x\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("x", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "x")
  assert_eq(printed.to_string(), "x\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:x", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "x", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets PlusLexerSingleElement" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_input(event) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u334.grammar()
  let parsed = grammar.parse_default(
    "bbbbc",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"bbbbc\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("bbbbc", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "bbbbc")
  assert_eq(printed.to_string(), "bbbbc\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:bbbbc", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "bbbbc", 0, 5, 1, 0, 0), (-1, "<EOF>", 5, 5, 1, 5, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets PlusSet" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_input(event) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u335.grammar()
  let parsed = grammar.parse_default(
    "abaac",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a\" \"b\" \"a\" \"a\" \"c\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("abaac", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "abaac")
  assert_eq(printed.to_string(), "abaac\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "token:b", "token:a", "token:a", "token:c", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (2, "b", 1, 2, 1, 1, 0),
      (1, "a", 2, 3, 1, 2, 0),
      (1, "a", 3, 4, 1, 3, 0),
      (3, "c", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets RuleAsSet" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_input(event) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u336.grammar()
  let parsed = grammar.parse_default(
    "b",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"b\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("b", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "b")
  assert_eq(printed.to_string(), "b\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:b", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(2, "b", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets SeqDoesNotBecomeSet" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_input(event) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u337.grammar()
  let parsed = grammar.parse_default(
    "34",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 2)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"34\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("34", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "34")
  assert_eq(printed.to_string(), "34\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:34", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "34", 0, 2, 1, 0, 0), (-1, "<EOF>", 2, 2, 1, 2, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets StarLexerSingleElement_1" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_input(event) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u338.grammar()
  let parsed = grammar.parse_default(
    "bbbbc",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"bbbbc\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("bbbbc", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "bbbbc")
  assert_eq(printed.to_string(), "bbbbc\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:bbbbc", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "bbbbc", 0, 5, 1, 0, 0), (-1, "<EOF>", 5, 5, 1, 5, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets StarLexerSingleElement_2" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_input(event) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u339.grammar()
  let parsed = grammar.parse_default(
    "c",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 1)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"c\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("c", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "c")
  assert_eq(printed.to_string(), "c\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:c", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "c", 0, 1, 1, 0, 0), (-1, "<EOF>", 1, 1, 1, 1, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets StarSet" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_input(event) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u340.grammar()
  let parsed = grammar.parse_default(
    "abaac",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a\" \"b\" \"a\" \"a\" \"c\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("abaac", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "abaac")
  assert_eq(printed.to_string(), "abaac\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "token:b", "token:a", "token:a", "token:c", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (1, "a", 0, 1, 1, 0, 0),
      (2, "b", 1, 2, 1, 1, 0),
      (1, "a", 2, 3, 1, 2, 0),
      (1, "a", 3, 4, 1, 3, 0),
      (3, "c", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets UnicodeEscapedBMPRangeSet" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_input(event) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u341.grammar()
  let parsed = grammar.parse_default(
    "aáäáâåd",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 7)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(a \"a\" \"á\" \"ä\" \"á\" \"â\" \"å\" \"d\")",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("aáäáâåd", lexer_action=(_, _) => {
    ()
  })
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "aáäáâåd")
  assert_eq(printed.to_string(), "aáäáâåd\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "token:á", "token:ä", "token:á", "token:â", "token:å",
    "token:d", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "a", 0, 1, 1, 0, 0),
      (2, "á", 1, 2, 1, 1, 0),
      (2, "ä", 2, 3, 1, 2, 0),
      (2, "á", 3, 4, 1, 3, 0),
      (2, "â", 4, 5, 1, 4, 0),
      (2, "å", 5, 6, 1, 5, 0),
      (1, "d", 6, 7, 1, 6, 0),
      (-1, "<EOF>", 7, 7, 1, 7, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets UnicodeEscapedBMPSet" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_input(event) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u342.grammar()
  let parsed = grammar.parse_default(
    "aäあ亜c",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"aäあ亜c\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("aäあ亜c", lexer_action=(_, _) => {
    ()
  })
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "aäあ亜c")
  assert_eq(printed.to_string(), "aäあ亜c\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:aäあ亜c", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "aäあ亜c", 0, 5, 1, 0, 0), (-1, "<EOF>", 5, 5, 1, 5, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets UnicodeEscapedSMPRangeSet" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_input(event) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u343.grammar()
  let parsed = grammar.parse_default(
    "a😉🥂🜀d",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(a \"a\" \"😉\" \"🥂\" \"🜀\" \"d\")",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a😉🥂🜀d", lexer_action=(_, _) => {
    ()
  })
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "a😉🥂🜀d")
  assert_eq(printed.to_string(), "a😉🥂🜀d\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "token:😉", "token:🥂", "token:🜀", "token:d", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "a", 0, 1, 1, 0, 0),
      (2, "😉", 1, 2, 1, 1, 0),
      (2, "🥂", 2, 3, 1, 2, 0),
      (2, "🜀", 3, 4, 1, 3, 0),
      (1, "d", 4, 5, 1, 4, 0),
      (-1, "<EOF>", 5, 5, 1, 5, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets UnicodeEscapedSMPRangeSetMismatch" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_input(event) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u344.grammar()
  let parsed = grammar.parse_default(
    "a🗿🥄d",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 4)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a\" \"d\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(1)),
    (Some(1), Some(2)),
  ])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a🗿🥄d", lexer_action=(_, _) => {
    ()
  })
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "ad")
  assert_eq(printed.to_string(), "ad\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "token:d", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "a", 0, 1, 1, 0, 0),
      (1, "d", 3, 4, 1, 3, 0),
      (-1, "<EOF>", 4, 4, 1, 4, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [(1, 1), (1, 2)],
  )
}

///|
test "upstream Sets UnicodeEscapedSMPSet" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_input(event) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u345.grammar()
  let parsed = grammar.parse_default(
    "a𝗂𝗎𝖺c",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a𝗂𝗎𝖺c\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a𝗂𝗎𝖺c", lexer_action=(_, _) => {
    ()
  })
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "a𝗂𝗎𝖺c")
  assert_eq(printed.to_string(), "a𝗂𝗎𝖺c\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a𝗂𝗎𝖺c", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "a𝗂𝗎𝖺c", 0, 5, 1, 0, 0), (-1, "<EOF>", 5, 5, 1, 5, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets UnicodeNegatedBMPSetIncludesSMPCodePoints" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_input(event) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u346.grammar()
  let parsed = grammar.parse_default(
    "a😳😡😝🤓c",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 6)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"a😳😡😝🤓c\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("a😳😡😝🤓c", lexer_action=(
    _,
    _,
  ) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "a😳😡😝🤓c")
  assert_eq(printed.to_string(), "a😳😡😝🤓c\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a😳😡😝🤓c", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "a😳😡😝🤓c", 0, 6, 1, 0, 0), (-1, "<EOF>", 6, 6, 1, 6, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets UnicodeNegatedSMPSetIncludesBMPCodePoints" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_input(event) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u347.grammar()
  let parsed = grammar.parse_default(
    "abc",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 3)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"abc\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("abc", lexer_action=(_, _) => ())
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "abc")
  assert_eq(printed.to_string(), "abc\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:abc", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "abc", 0, 3, 1, 0, 0), (-1, "<EOF>", 3, 3, 1, 3, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets UnicodeUnescapedBMPRangeSet" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_input(event) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u348.grammar()
  let parsed = grammar.parse_default(
    "aáäáâåd",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 7)])
  assert_eq(
    parsed.tree.to_sexpr(),
    "(a \"a\" \"á\" \"ä\" \"á\" \"â\" \"å\" \"d\")",
  )
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("aáäáâåd", lexer_action=(_, _) => {
    ()
  })
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "aáäáâåd")
  assert_eq(printed.to_string(), "aáäáâåd\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:a", "token:á", "token:ä", "token:á", "token:â", "token:å",
    "token:d", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [
      (2, "a", 0, 1, 1, 0, 0),
      (2, "á", 1, 2, 1, 1, 0),
      (2, "ä", 2, 3, 1, 2, 0),
      (2, "á", 3, 4, 1, 3, 0),
      (2, "â", 4, 5, 1, 4, 0),
      (2, "å", 5, 6, 1, 5, 0),
      (1, "d", 6, 7, 1, 6, 0),
      (-1, "<EOF>", 7, 7, 1, 7, 0),
    ],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}

///|
test "upstream Sets UnicodeUnescapedBMPSet" {
  let printed = StringBuilder()
  let bindings : @runtime.RuleSemantics = {
    ..@runtime.RuleSemantics::new(),
    action: (event, ordinal) => {
      match ordinal {
        0 => printed.write_string(observed_input(event) + "\n")
        _ => ()
      }
      event.frame
    },
  }
  let lexer_observer : @runtime.LexerAction = (event, source) => {
    ignore(event)
    ignore(source)
    match (event.rule, event.action) {
      _ => raise @runtime.InvalidArgument("unbound lexer observation")
    }
  }
  let actions : Array[(Int32, Int32)] = []
  let grammar = @u349.grammar()
  let parsed = grammar.parse_default(
    "aäあ亜c",
    report_prediction=false,
    build_tree=true,
    prediction_mode=@runtime.LL,
    start_rule=0,
    semantics=bindings,
    shared=Map([]),
    lexer_action=lexer_observer,
    parser_action=event => actions.push((event.action, event.next_token.start)),
  )
  @debug.assert_eq(actions, [(0, 5)])
  assert_eq(parsed.tree.to_sexpr(), "(a \"aäあ亜c\")")
  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [])
  @debug.assert_eq(
    parsed.tree
    .error_tokens()
    .map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)),
    [],
  )
  assert_eq(parsed.next_token.kind, -1)
  assert_eq(parsed.next_token.text, "<EOF>")
  let lexed = grammar.tokenize_recovering("aäあ亜c", lexer_action=(_, _) => {
    ()
  })
  assert_eq(
    bound_frame_json(parsed.frame.unwrap(), build_tree=true),
    @json.parse("{\"values\":{},\"children\":[]}"),
  )
  assert_eq(parsed.context.get_text(), "aäあ亜c")
  assert_eq(printed.to_string(), "aäあ亜c\n")
  @debug.assert_eq(bound_listener_events(parsed.tree), [
    "enter:a", "token:aäあ亜c", "exit:a",
  ])
  @debug.assert_eq(
    lexed.tokens.map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    }),
    [(1, "aäあ亜c", 0, 5, 1, 0, 0), (-1, "<EOF>", 5, 5, 1, 5, 0)],
  )
  @debug.assert_eq(
    lexed.errors.map(e => {
      match e {
        @runtime.LexicalError(line, col, _) => (line, col)
        _ => (-1, -1)
      }
    }),
    [],
  )
}
