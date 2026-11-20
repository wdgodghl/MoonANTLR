// Generated original C# grammar Java comparisons.

///|
test "CSharp Java 000 directives" {
  @debug.assert_eq(
    @csharp.directives(
      "#define FEATURE\n#if FEATURE && !false\n#else\n#endif\n",
    ),
    [true, true, false, true],
  )
  let tokens = @csharp.tokenize(
    "#define FEATURE\n#if FEATURE && !false\n#else\n#endif\n",
  ).map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel))
  @debug.assert_eq(tokens, [
    (183, "define", 1, 7, 1, 1, 3),
    (181, " ", 7, 8, 1, 7, 1),
    (195, "FEATURE", 8, 15, 1, 8, 3),
    (196, "\n", 15, 16, 1, 15, 3),
    (52, "if", 17, 19, 2, 1, 3),
    (181, " ", 19, 20, 2, 3, 1),
    (195, "FEATURE", 20, 27, 2, 4, 3),
    (181, " ", 27, 28, 2, 11, 1),
    (153, "&&", 28, 30, 2, 12, 3),
    (181, " ", 30, 31, 2, 14, 1),
    (143, "!", 31, 32, 2, 15, 3),
    (42, "false", 32, 37, 2, 16, 3),
    (196, "\n", 37, 38, 2, 21, 3),
    (36, "else", 39, 43, 3, 1, 3),
    (196, "\n", 43, 44, 3, 5, 3),
    (186, "endif", 45, 50, 4, 1, 3),
    (196, "\n", 50, 51, 4, 6, 3),
    (-1, "<EOF>", 51, 51, 5, 0, 0),
  ])
}

///|
test "CSharp Java 001 directives" {
  @debug.assert_eq(
    @csharp.directives("#define X\n#undef X\n#if X\n#else\n#endif\n"),
    [true, true, false, true, true],
  )
  let tokens = @csharp.tokenize("#define X\n#undef X\n#if X\n#else\n#endif\n").map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    },
  )
  @debug.assert_eq(tokens, [
    (183, "define", 1, 7, 1, 1, 3),
    (181, " ", 7, 8, 1, 7, 1),
    (195, "X", 8, 9, 1, 8, 3),
    (196, "\n", 9, 10, 1, 9, 3),
    (184, "undef", 11, 16, 2, 1, 3),
    (181, " ", 16, 17, 2, 6, 1),
    (195, "X", 17, 18, 2, 7, 3),
    (196, "\n", 18, 19, 2, 8, 3),
    (52, "if", 20, 22, 3, 1, 3),
    (181, " ", 22, 23, 3, 3, 1),
    (195, "X", 23, 24, 3, 4, 3),
    (196, "\n", 24, 25, 3, 5, 3),
    (36, "else", 26, 30, 4, 1, 3),
    (196, "\n", 30, 31, 4, 5, 3),
    (186, "endif", 32, 37, 5, 1, 3),
    (196, "\n", 37, 38, 5, 6, 3),
    (-1, "<EOF>", 38, 38, 6, 0, 0),
  ])
}

///|
test "CSharp Java 002 directives" {
  @debug.assert_eq(
    @csharp.directives("#if false\n#if true\n#else\n#endif\n#else\n#endif\n"),
    [false, false, false, false, true, true],
  )
  let tokens = @csharp.tokenize(
    "#if false\n#if true\n#else\n#endif\n#else\n#endif\n",
  ).map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel))
  @debug.assert_eq(tokens, [
    (52, "if", 1, 3, 1, 1, 3),
    (181, " ", 3, 4, 1, 3, 1),
    (42, "false", 4, 9, 1, 4, 3),
    (196, "\n", 9, 10, 1, 9, 3),
    (52, "if", 11, 13, 2, 1, 3),
    (181, " ", 13, 14, 2, 3, 1),
    (96, "true", 14, 18, 2, 4, 3),
    (196, "\n", 18, 19, 2, 8, 3),
    (36, "else", 20, 24, 3, 1, 3),
    (196, "\n", 24, 25, 3, 5, 3),
    (186, "endif", 26, 31, 4, 1, 3),
    (196, "\n", 31, 32, 4, 6, 3),
    (36, "else", 33, 37, 5, 1, 3),
    (196, "\n", 37, 38, 5, 5, 3),
    (186, "endif", 39, 44, 6, 1, 3),
    (196, "\n", 44, 45, 6, 6, 3),
    (-1, "<EOF>", 45, 45, 7, 0, 0),
  ])
}

///|
test "CSharp Java 003 directives" {
  @debug.assert_eq(
    @csharp.directives("#if false\n#elif DEBUG\n#else\n#endif\n"),
    [false, true, false, true],
  )
  let tokens = @csharp.tokenize("#if false\n#elif DEBUG\n#else\n#endif\n").map(t => {
    (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
  })
  @debug.assert_eq(tokens, [
    (52, "if", 1, 3, 1, 1, 3),
    (181, " ", 3, 4, 1, 3, 1),
    (42, "false", 4, 9, 1, 4, 3),
    (196, "\n", 9, 10, 1, 9, 3),
    (185, "elif", 11, 15, 2, 1, 3),
    (181, " ", 15, 16, 2, 5, 1),
    (195, "DEBUG", 16, 21, 2, 6, 3),
    (196, "\n", 21, 22, 2, 11, 3),
    (36, "else", 23, 27, 3, 1, 3),
    (196, "\n", 27, 28, 3, 5, 3),
    (186, "endif", 29, 34, 4, 1, 3),
    (196, "\n", 34, 35, 4, 6, 3),
    (-1, "<EOF>", 35, 35, 5, 0, 0),
  ])
}

///|
test "CSharp Java 004 directives" {
  @debug.assert_eq(
    @csharp.directives("#if (DEBUG && true) || false\n#endif\n"),
    [true, true],
  )
  let tokens = @csharp.tokenize("#if (DEBUG && true) || false\n#endif\n").map(t => {
    (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
  })
  @debug.assert_eq(tokens, [
    (52, "if", 1, 3, 1, 1, 3),
    (181, " ", 3, 4, 1, 3, 1),
    (129, "(", 4, 5, 1, 4, 3),
    (195, "DEBUG", 5, 10, 1, 5, 3),
    (181, " ", 10, 11, 1, 10, 1),
    (153, "&&", 11, 13, 1, 11, 3),
    (181, " ", 13, 14, 1, 13, 1),
    (96, "true", 14, 18, 1, 14, 3),
    (130, ")", 18, 19, 1, 18, 3),
    (181, " ", 19, 20, 1, 19, 1),
    (154, "||", 20, 22, 1, 20, 3),
    (181, " ", 22, 23, 1, 22, 1),
    (42, "false", 23, 28, 1, 23, 3),
    (196, "\n", 28, 29, 1, 28, 3),
    (186, "endif", 30, 35, 2, 1, 3),
    (196, "\n", 35, 36, 2, 6, 3),
    (-1, "<EOF>", 36, 36, 3, 0, 0),
  ])
}

///|
test "CSharp Java 005 directives" {
  @debug.assert_eq(@csharp.directives("#if DEBUG == true\n#endif\n"), [
    true, true,
  ])
  let tokens = @csharp.tokenize("#if DEBUG == true\n#endif\n").map(t => {
    (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
  })
  @debug.assert_eq(tokens, [
    (52, "if", 1, 3, 1, 1, 3),
    (181, " ", 3, 4, 1, 3, 1),
    (195, "DEBUG", 4, 9, 1, 4, 3),
    (181, " ", 9, 10, 1, 9, 1),
    (156, "==", 10, 12, 1, 10, 3),
    (181, " ", 12, 13, 1, 12, 1),
    (96, "true", 13, 17, 1, 13, 3),
    (196, "\n", 17, 18, 1, 17, 3),
    (186, "endif", 19, 24, 2, 1, 3),
    (196, "\n", 24, 25, 2, 6, 3),
    (-1, "<EOF>", 25, 25, 3, 0, 0),
  ])
}

///|
test "CSharp Java 006 directives" {
  @debug.assert_eq(@csharp.directives("#if DEBUG != false\n#endif\n"), [
    true, true,
  ])
  let tokens = @csharp.tokenize("#if DEBUG != false\n#endif\n").map(t => {
    (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
  })
  @debug.assert_eq(tokens, [
    (52, "if", 1, 3, 1, 1, 3),
    (181, " ", 3, 4, 1, 3, 1),
    (195, "DEBUG", 4, 9, 1, 4, 3),
    (181, " ", 9, 10, 1, 9, 1),
    (157, "!=", 10, 12, 1, 10, 3),
    (181, " ", 12, 13, 1, 12, 1),
    (42, "false", 13, 18, 1, 13, 3),
    (196, "\n", 18, 19, 1, 18, 3),
    (186, "endif", 20, 25, 2, 1, 3),
    (196, "\n", 25, 26, 2, 6, 3),
    (-1, "<EOF>", 26, 26, 3, 0, 0),
  ])
}

///|
test "CSharp Java 007 directives" {
  @debug.assert_eq(
    @csharp.directives("#line 42 \"sample.cs\"\n#line default\n#line hidden\n"),
    [true, true, true],
  )
  let tokens = @csharp.tokenize(
    "#line 42 \"sample.cs\"\n#line default\n#line hidden\n",
  ).map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel))
  @debug.assert_eq(tokens, [
    (187, "line", 1, 5, 1, 1, 3),
    (181, " ", 5, 6, 1, 5, 1),
    (182, "42", 6, 8, 1, 6, 3),
    (181, " ", 8, 9, 1, 8, 1),
    (91, "\"sample.cs\"", 9, 20, 1, 9, 3),
    (196, "\n", 20, 21, 1, 20, 3),
    (187, "line", 22, 26, 2, 1, 3),
    (181, " ", 26, 27, 2, 5, 1),
    (30, "default", 27, 34, 2, 6, 3),
    (196, "\n", 34, 35, 2, 13, 3),
    (187, "line", 36, 40, 3, 1, 3),
    (181, " ", 40, 41, 3, 5, 1),
    (194, "hidden", 41, 47, 3, 6, 3),
    (196, "\n", 47, 48, 3, 12, 3),
    (-1, "<EOF>", 48, 48, 4, 0, 0),
  ])
}

///|
test "CSharp Java 008 directives" {
  @debug.assert_eq(@csharp.directives("#region title\n#endregion title\n"), [
    true, true,
  ])
  let tokens = @csharp.tokenize("#region title\n#endregion title\n").map(t => {
    (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
  })
  @debug.assert_eq(tokens, [
    (190, "region ", 1, 8, 1, 1, 3),
    (197, "title", 8, 13, 1, 8, 3),
    (196, "\n", 13, 14, 1, 13, 3),
    (191, "endregion ", 15, 25, 2, 1, 3),
    (197, "title", 25, 30, 2, 11, 3),
    (196, "\n", 30, 31, 2, 16, 3),
    (-1, "<EOF>", 31, 31, 3, 0, 0),
  ])
}

///|
test "CSharp Java 009 directives" {
  @debug.assert_eq(
    @csharp.directives("#pragma warning disable\n#nullable enable\n"),
    [true, true],
  )
  let tokens = @csharp.tokenize("#pragma warning disable\n#nullable enable\n").map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    },
  )
  @debug.assert_eq(tokens, [
    (192, "pragma ", 1, 8, 1, 1, 3),
    (197, "warning disable", 8, 23, 1, 8, 3),
    (196, "\n", 23, 24, 1, 23, 3),
    (193, "nullable ", 25, 34, 2, 1, 3),
    (197, "enable", 34, 40, 2, 10, 3),
    (196, "\n", 40, 41, 2, 16, 3),
    (-1, "<EOF>", 41, 41, 3, 0, 0),
  ])
}

///|
test "CSharp Java 010 directives" {
  @debug.assert_eq(@csharp.directives("#warning message\n#error message\n"), [
    true, true,
  ])
  let tokens = @csharp.tokenize("#warning message\n#error message\n").map(t => {
    (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
  })
  @debug.assert_eq(tokens, [
    (189, "warning ", 1, 9, 1, 1, 3),
    (197, "message", 9, 16, 1, 9, 3),
    (196, "\n", 16, 17, 1, 16, 3),
    (188, "error ", 18, 24, 2, 1, 3),
    (197, "message", 24, 31, 2, 7, 3),
    (196, "\n", 31, 32, 2, 14, 3),
    (-1, "<EOF>", 32, 32, 3, 0, 0),
  ])
}

///|
test "CSharp Java 011 directives" {
  @debug.assert_eq(
    @csharp.directives("#if false\n#define X\n#endif\n#if X\n#endif\n"),
    [false, false, true, true, true],
  )
  let tokens = @csharp.tokenize("#if false\n#define X\n#endif\n#if X\n#endif\n").map(t => {
      (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
    },
  )
  @debug.assert_eq(tokens, [
    (52, "if", 1, 3, 1, 1, 3),
    (181, " ", 3, 4, 1, 3, 1),
    (42, "false", 4, 9, 1, 4, 3),
    (196, "\n", 9, 10, 1, 9, 3),
    (183, "define", 11, 17, 2, 1, 3),
    (181, " ", 17, 18, 2, 7, 1),
    (195, "X", 18, 19, 2, 8, 3),
    (196, "\n", 19, 20, 2, 9, 3),
    (186, "endif", 21, 26, 3, 1, 3),
    (196, "\n", 26, 27, 3, 6, 3),
    (52, "if", 28, 30, 4, 1, 3),
    (181, " ", 30, 31, 4, 3, 1),
    (195, "X", 31, 32, 4, 4, 3),
    (196, "\n", 32, 33, 4, 5, 3),
    (186, "endif", 34, 39, 5, 1, 3),
    (196, "\n", 39, 40, 5, 6, 3),
    (-1, "<EOF>", 40, 40, 6, 0, 0),
  ])
}

///|
test "CSharp Java 012 directives" {
  @debug.assert_eq(
    @csharp.directives("#if DEBUG\n#elif false\n#else\n#endif\n"),
    [true, false, false, true],
  )
  let tokens = @csharp.tokenize("#if DEBUG\n#elif false\n#else\n#endif\n").map(t => {
    (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
  })
  @debug.assert_eq(tokens, [
    (52, "if", 1, 3, 1, 1, 3),
    (181, " ", 3, 4, 1, 3, 1),
    (195, "DEBUG", 4, 9, 1, 4, 3),
    (196, "\n", 9, 10, 1, 9, 3),
    (185, "elif", 11, 15, 2, 1, 3),
    (181, " ", 15, 16, 2, 5, 1),
    (42, "false", 16, 21, 2, 6, 3),
    (196, "\n", 21, 22, 2, 11, 3),
    (36, "else", 23, 27, 3, 1, 3),
    (196, "\n", 27, 28, 3, 5, 3),
    (186, "endif", 29, 34, 4, 1, 3),
    (196, "\n", 34, 35, 4, 6, 3),
    (-1, "<EOF>", 35, 35, 5, 0, 0),
  ])
}

///|
test "CSharp Java 013 expression" {
  assert_eq(
    @csharp.parse("8 >> 1", rule="expression").context.to_tree().to_sexpr(),
    "(expression (non_assignment_expression (conditional_expression (null_coalescing_expression (conditional_or_expression (conditional_and_expression (inclusive_or_expression (exclusive_or_expression (and_expression (equality_expression (relational_expression (shift_expression (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"8\")))))))) (right_shift \">\" \">\") (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"1\"))))))))))))))))))))",
  )
  let tokens = @csharp.tokenize("8 >> 1").map(t => {
    (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
  })
  @debug.assert_eq(tokens, [
    (116, "8", 0, 1, 1, 0, 0),
    (7, " ", 1, 2, 1, 1, 1),
    (147, ">", 2, 3, 1, 2, 0),
    (147, ">", 3, 4, 1, 3, 0),
    (7, " ", 4, 5, 1, 4, 1),
    (116, "1", 5, 6, 1, 5, 0),
    (-1, "<EOF>", 6, 6, 1, 6, 0),
  ])
}

///|
test "CSharp Java recovery 013 expression" {
  let result = @csharp.parse_recovering("8 >> 1", rule="expression")
  assert_eq(
    result.tree.to_sexpr(),
    "(expression (non_assignment_expression (conditional_expression (null_coalescing_expression (conditional_or_expression (conditional_and_expression (inclusive_or_expression (exclusive_or_expression (and_expression (equality_expression (relational_expression (shift_expression (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"8\")))))))) (right_shift \">\" \">\") (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"1\"))))))))))))))))))))",
  )
  @debug.assert_eq(result.diagnostics.map(d => (d.line, d.column)), [])
}

///|
test "CSharp Java 014 expression" {
  let rejected = try {
    let _ = @csharp.parse("8 > > 1", rule="expression")
    false
  } catch {
    @runtime.SyntaxError(_, _, _) => true
    _ => false
  }
  assert_true(rejected)
}

///|
test "CSharp Java recovery 014 expression" {
  let result = @csharp.parse_recovering("8 > > 1", rule="expression")
  assert_eq(
    result.tree.to_sexpr(),
    "(expression (non_assignment_expression (conditional_expression (null_coalescing_expression (conditional_or_expression (conditional_and_expression (inclusive_or_expression (exclusive_or_expression (and_expression (equality_expression (relational_expression (shift_expression (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"8\")))))))) (right_shift \">\" \">\") (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"1\"))))))))))))))))))))",
  )
  @debug.assert_eq(result.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(6)),
  ])
}

///|
test "CSharp Java 015 expression" {
  let rejected = try {
    let _ = @csharp.parse("8 >/*gap*/> 1", rule="expression")
    false
  } catch {
    @runtime.SyntaxError(_, _, _) => true
    _ => false
  }
  assert_true(rejected)
}

///|
test "CSharp Java recovery 015 expression" {
  let result = @csharp.parse_recovering("8 >/*gap*/> 1", rule="expression")
  assert_eq(
    result.tree.to_sexpr(),
    "(expression (non_assignment_expression (conditional_expression (null_coalescing_expression (conditional_or_expression (conditional_and_expression (inclusive_or_expression (exclusive_or_expression (and_expression (equality_expression (relational_expression (shift_expression (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"8\")))))))) (right_shift \">\" \">\") (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"1\"))))))))))))))))))))",
  )
  @debug.assert_eq(result.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(12)),
  ])
}

///|
test "CSharp Java 016 declarationStatement" {
  assert_eq(
    @csharp.parse("int x=1,y=2;", rule="declarationStatement").context
    .to_tree()
    .to_sexpr(),
    "(declarationStatement (local_variable_declaration (local_variable_type (type_ (base_type (simple_type (numeric_type (integral_type \"int\")))))) (local_variable_declarator (identifier \"x\") \"=\" (local_variable_initializer (expression (non_assignment_expression (conditional_expression (null_coalescing_expression (conditional_or_expression (conditional_and_expression (inclusive_or_expression (exclusive_or_expression (and_expression (equality_expression (relational_expression (shift_expression (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"1\")))))))))))))))))))))) \",\" (local_variable_declarator (identifier \"y\") \"=\" (local_variable_initializer (expression (non_assignment_expression (conditional_expression (null_coalescing_expression (conditional_or_expression (conditional_and_expression (inclusive_or_expression (exclusive_or_expression (and_expression (equality_expression (relational_expression (shift_expression (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"2\"))))))))))))))))))))))) \";\")",
  )
  let tokens = @csharp.tokenize("int x=1,y=2;").map(t => {
    (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
  })
  @debug.assert_eq(tokens, [
    (55, "int", 0, 3, 1, 0, 0),
    (7, " ", 3, 4, 1, 3, 1),
    (114, "x", 4, 5, 1, 4, 0),
    (145, "=", 5, 6, 1, 5, 0),
    (116, "1", 6, 7, 1, 6, 0),
    (132, ",", 7, 8, 1, 7, 0),
    (114, "y", 8, 9, 1, 8, 0),
    (145, "=", 9, 10, 1, 9, 0),
    (116, "2", 10, 11, 1, 10, 0),
    (134, ";", 11, 12, 1, 11, 0),
    (-1, "<EOF>", 12, 12, 1, 12, 0),
  ])
}

///|
test "CSharp Java recovery 016 declarationStatement" {
  let result = @csharp.parse_recovering(
    "int x=1,y=2;",
    rule="declarationStatement",
  )
  assert_eq(
    result.tree.to_sexpr(),
    "(declarationStatement (local_variable_declaration (local_variable_type (type_ (base_type (simple_type (numeric_type (integral_type \"int\")))))) (local_variable_declarator (identifier \"x\") \"=\" (local_variable_initializer (expression (non_assignment_expression (conditional_expression (null_coalescing_expression (conditional_or_expression (conditional_and_expression (inclusive_or_expression (exclusive_or_expression (and_expression (equality_expression (relational_expression (shift_expression (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"1\")))))))))))))))))))))) \",\" (local_variable_declarator (identifier \"y\") \"=\" (local_variable_initializer (expression (non_assignment_expression (conditional_expression (null_coalescing_expression (conditional_or_expression (conditional_and_expression (inclusive_or_expression (exclusive_or_expression (and_expression (equality_expression (relational_expression (shift_expression (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"2\"))))))))))))))))))))))) \";\")",
  )
  @debug.assert_eq(result.diagnostics.map(d => (d.line, d.column)), [])
}

///|
test "CSharp Java 017 declarationStatement" {
  let rejected = try {
    let _ = @csharp.parse("var x=1,y=2;", rule="declarationStatement")
    false
  } catch {
    @runtime.SyntaxError(_, _, _) => true
    _ => false
  }
  assert_true(rejected)
}

///|
test "CSharp Java recovery 017 declarationStatement" {
  let result = @csharp.parse_recovering(
    "var x=1,y=2;",
    rule="declarationStatement",
  )
  assert_eq(
    result.tree.to_sexpr(),
    "(declarationStatement (local_variable_declaration (local_variable_type \"var\") (local_variable_declarator (identifier \"x\") \"=\" (local_variable_initializer (expression (non_assignment_expression (conditional_expression (null_coalescing_expression (conditional_or_expression (conditional_and_expression (inclusive_or_expression (exclusive_or_expression (and_expression (equality_expression (relational_expression (shift_expression (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"1\")))))))))))))))))))))) \",\" (local_variable_declarator (identifier \"y\") \"=\" (local_variable_initializer (expression (non_assignment_expression (conditional_expression (null_coalescing_expression (conditional_or_expression (conditional_and_expression (inclusive_or_expression (exclusive_or_expression (and_expression (equality_expression (relational_expression (shift_expression (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"2\"))))))))))))))))))))))) \";\")",
  )
  @debug.assert_eq(result.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(11)),
  ])
}

///|
test "CSharp Java 018 declarationStatement" {
  assert_eq(
    @csharp.parse("var x=1;", rule="declarationStatement").context
    .to_tree()
    .to_sexpr(),
    "(declarationStatement (local_variable_declaration (local_variable_type \"var\") (local_variable_declarator (identifier \"x\") \"=\" (local_variable_initializer (expression (non_assignment_expression (conditional_expression (null_coalescing_expression (conditional_or_expression (conditional_and_expression (inclusive_or_expression (exclusive_or_expression (and_expression (equality_expression (relational_expression (shift_expression (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"1\"))))))))))))))))))))))) \";\")",
  )
  let tokens = @csharp.tokenize("var x=1;").map(t => {
    (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
  })
  @debug.assert_eq(tokens, [
    (106, "var", 0, 3, 1, 0, 0),
    (7, " ", 3, 4, 1, 3, 1),
    (114, "x", 4, 5, 1, 4, 0),
    (145, "=", 5, 6, 1, 5, 0),
    (116, "1", 6, 7, 1, 6, 0),
    (134, ";", 7, 8, 1, 7, 0),
    (-1, "<EOF>", 8, 8, 1, 8, 0),
  ])
}

///|
test "CSharp Java recovery 018 declarationStatement" {
  let result = @csharp.parse_recovering("var x=1;", rule="declarationStatement")
  assert_eq(
    result.tree.to_sexpr(),
    "(declarationStatement (local_variable_declaration (local_variable_type \"var\") (local_variable_declarator (identifier \"x\") \"=\" (local_variable_initializer (expression (non_assignment_expression (conditional_expression (null_coalescing_expression (conditional_or_expression (conditional_and_expression (inclusive_or_expression (exclusive_or_expression (and_expression (equality_expression (relational_expression (shift_expression (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"1\"))))))))))))))))))))))) \";\")",
  )
  @debug.assert_eq(result.diagnostics.map(d => (d.line, d.column)), [])
}

///|
test "CSharp Java 019 tokens" {
  let tokens = @csharp.tokenize("$\"value={1+2}\"").map(t => {
    (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
  })
  @debug.assert_eq(tokens, [
    (123, "$\"", 0, 2, 1, 0, 0),
    (177, "value=", 2, 8, 1, 2, 0),
    (116, "1", 9, 10, 1, 9, 0),
    (135, "+", 10, 11, 1, 10, 0),
    (116, "2", 11, 12, 1, 11, 0),
    (176, "\"", 13, 14, 1, 13, 0),
    (-1, "<EOF>", 14, 14, 1, 14, 0),
  ])
}

///|
test "CSharp Java 020 tokens" {
  let tokens = @csharp.tokenize("$@\"a\"\"b{1}\"").map(t => {
    (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
  })
  @debug.assert_eq(tokens, [
    (124, "$@\"", 0, 3, 1, 0, 0),
    (178, "a", 3, 4, 1, 3, 0),
    (175, "\"\"", 4, 6, 1, 4, 0),
    (178, "b", 6, 7, 1, 6, 0),
    (116, "1", 8, 9, 1, 8, 0),
    (176, "\"", 10, 11, 1, 10, 0),
    (-1, "<EOF>", 11, 11, 1, 11, 0),
  ])
}

///|
test "CSharp Java 021 tokens" {
  let tokens = @csharp.tokenize("$\"value={1:00}\"").map(t => {
    (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
  })
  @debug.assert_eq(tokens, [
    (123, "$\"", 0, 2, 1, 0, 0),
    (177, "value=", 2, 8, 1, 2, 0),
    (116, "1", 9, 10, 1, 9, 0),
    (133, ":", 10, 11, 1, 10, 0),
    (180, "00", 11, 13, 1, 11, 0),
    (176, "\"", 14, 15, 1, 14, 0),
    (-1, "<EOF>", 15, 15, 1, 15, 0),
  ])
}

///|
test "CSharp Java 022 tokens" {
  let tokens = @csharp.tokenize("$\"a{new object { }}b\"").map(t => {
    (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
  })
  @debug.assert_eq(tokens, [
    (123, "$\"", 0, 2, 1, 0, 0),
    (177, "a", 2, 3, 1, 2, 0),
    (66, "new", 4, 7, 1, 4, 0),
    (7, " ", 7, 8, 1, 7, 1),
    (68, "object", 8, 14, 1, 8, 0),
    (7, " ", 14, 15, 1, 14, 1),
    (125, "{", 15, 16, 1, 15, 0),
    (7, " ", 16, 17, 1, 16, 1),
    (126, "}", 17, 18, 1, 17, 0),
    (177, "b", 19, 20, 1, 19, 0),
    (176, "\"", 20, 21, 1, 20, 0),
    (-1, "<EOF>", 21, 21, 1, 21, 0),
  ])
}

///|
test "CSharp Java 023 tokens" {
  let tokens = @csharp.tokenize("$\"a{1}\" $\"b{2}\"").map(t => {
    (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
  })
  @debug.assert_eq(tokens, [
    (123, "$\"", 0, 2, 1, 0, 0),
    (177, "a", 2, 3, 1, 2, 0),
    (116, "1", 4, 5, 1, 4, 0),
    (176, "\"", 6, 7, 1, 6, 0),
    (7, " ", 7, 8, 1, 7, 1),
    (123, "$\"", 8, 10, 1, 8, 0),
    (177, "b", 10, 11, 1, 10, 0),
    (116, "2", 12, 13, 1, 12, 0),
    (176, "\"", 14, 15, 1, 14, 0),
    (-1, "<EOF>", 15, 15, 1, 15, 0),
  ])
}

///|
test "CSharp Java 024 tokens" {
  let tokens = @csharp.tokenize("$\"line\\n={1}\"").map(t => {
    (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
  })
  @debug.assert_eq(tokens, [
    (123, "$\"", 0, 2, 1, 0, 0),
    (177, "line", 2, 6, 1, 2, 0),
    (174, "\\n", 6, 8, 1, 6, 0),
    (177, "=", 8, 9, 1, 8, 0),
    (116, "1", 10, 11, 1, 10, 0),
    (176, "\"", 12, 13, 1, 12, 0),
    (-1, "<EOF>", 13, 13, 1, 13, 0),
  ])
}

///|
test "CSharp Java 025 tokens" {
  let tokens = @csharp.tokenize("$\"😀={1}\"").map(t => {
    (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
  })
  @debug.assert_eq(tokens, [
    (123, "$\"", 0, 2, 1, 0, 0),
    (177, "😀=", 2, 4, 1, 2, 0),
    (116, "1", 5, 6, 1, 5, 0),
    (176, "\"", 7, 8, 1, 7, 0),
    (-1, "<EOF>", 8, 8, 1, 8, 0),
  ])
}

///|
test "CSharp Java 026 declarationStatement" {
  assert_eq(
    @csharp.parse("int 变量=1;", rule="declarationStatement").context
    .to_tree()
    .to_sexpr(),
    "(declarationStatement (local_variable_declaration (local_variable_type (type_ (base_type (simple_type (numeric_type (integral_type \"int\")))))) (local_variable_declarator (identifier \"\u53d8\u91cf\") \"=\" (local_variable_initializer (expression (non_assignment_expression (conditional_expression (null_coalescing_expression (conditional_or_expression (conditional_and_expression (inclusive_or_expression (exclusive_or_expression (and_expression (equality_expression (relational_expression (shift_expression (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"1\"))))))))))))))))))))))) \";\")",
  )
  let tokens = @csharp.tokenize("int 变量=1;").map(t => {
    (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
  })
  @debug.assert_eq(tokens, [
    (55, "int", 0, 3, 1, 0, 0),
    (7, " ", 3, 4, 1, 3, 1),
    (114, "变量", 4, 6, 1, 4, 0),
    (145, "=", 6, 7, 1, 6, 0),
    (116, "1", 7, 8, 1, 7, 0),
    (134, ";", 8, 9, 1, 8, 0),
    (-1, "<EOF>", 9, 9, 1, 9, 0),
  ])
}

///|
test "CSharp Java recovery 026 declarationStatement" {
  let result = @csharp.parse_recovering(
    "int 变量=1;",
    rule="declarationStatement",
  )
  assert_eq(
    result.tree.to_sexpr(),
    "(declarationStatement (local_variable_declaration (local_variable_type (type_ (base_type (simple_type (numeric_type (integral_type \"int\")))))) (local_variable_declarator (identifier \"变量\") \"=\" (local_variable_initializer (expression (non_assignment_expression (conditional_expression (null_coalescing_expression (conditional_or_expression (conditional_and_expression (inclusive_or_expression (exclusive_or_expression (and_expression (equality_expression (relational_expression (shift_expression (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"1\"))))))))))))))))))))))) \";\")",
  )
  @debug.assert_eq(result.diagnostics.map(d => (d.line, d.column)), [])
}

///|
test "CSharp Java 027 compilation_unit" {
  assert_eq(
    @csharp.parse(
      "class C { int x; void F() { return; } }",
      rule="compilation_unit",
    ).context
    .to_tree()
    .to_sexpr(),
    "(compilation_unit (namespace_member_declarations (namespace_member_declaration (type_declaration (class_definition \"class\" (identifier \"C\") (class_body \"{\" (class_member_declarations (class_member_declaration (common_member_declaration (typed_member_declaration (type_ (base_type (simple_type (numeric_type (integral_type \"int\"))))) (field_declaration (variable_declarators (variable_declarator (identifier \"x\"))) \";\")))) (class_member_declaration (common_member_declaration \"void\" (method_declaration (method_member_name (identifier \"F\")) \"(\" \")\" (method_body (block \"{\" (statement_list (statement (embedded_statement (simple_embedded_statement \"return\" \";\")))) \"}\")))))) \"}\"))))) <EOF>)",
  )
  let tokens = @csharp.tokenize("class C { int x; void F() { return; } }").map(t => {
    (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
  })
  @debug.assert_eq(tokens, [
    (26, "class", 0, 5, 1, 0, 0),
    (7, " ", 5, 6, 1, 5, 1),
    (114, "C", 6, 7, 1, 6, 0),
    (7, " ", 7, 8, 1, 7, 1),
    (125, "{", 8, 9, 1, 8, 0),
    (7, " ", 9, 10, 1, 9, 1),
    (55, "int", 10, 13, 1, 10, 0),
    (7, " ", 13, 14, 1, 13, 1),
    (114, "x", 14, 15, 1, 14, 0),
    (134, ";", 15, 16, 1, 15, 0),
    (7, " ", 16, 17, 1, 16, 1),
    (108, "void", 17, 21, 1, 17, 0),
    (7, " ", 21, 22, 1, 21, 1),
    (114, "F", 22, 23, 1, 22, 0),
    (129, "(", 23, 24, 1, 23, 0),
    (130, ")", 24, 25, 1, 24, 0),
    (7, " ", 25, 26, 1, 25, 1),
    (125, "{", 26, 27, 1, 26, 0),
    (7, " ", 27, 28, 1, 27, 1),
    (82, "return", 28, 34, 1, 28, 0),
    (134, ";", 34, 35, 1, 34, 0),
    (7, " ", 35, 36, 1, 35, 1),
    (126, "}", 36, 37, 1, 36, 0),
    (7, " ", 37, 38, 1, 37, 1),
    (126, "}", 38, 39, 1, 38, 0),
    (-1, "<EOF>", 39, 39, 1, 39, 0),
  ])
}

///|
test "CSharp Java recovery 027 compilation_unit" {
  let result = @csharp.parse_recovering(
    "class C { int x; void F() { return; } }",
    rule="compilation_unit",
  )
  assert_eq(
    result.tree.to_sexpr(),
    "(compilation_unit (namespace_member_declarations (namespace_member_declaration (type_declaration (class_definition \"class\" (identifier \"C\") (class_body \"{\" (class_member_declarations (class_member_declaration (common_member_declaration (typed_member_declaration (type_ (base_type (simple_type (numeric_type (integral_type \"int\"))))) (field_declaration (variable_declarators (variable_declarator (identifier \"x\"))) \";\")))) (class_member_declaration (common_member_declaration \"void\" (method_declaration (method_member_name (identifier \"F\")) \"(\" \")\" (method_body (block \"{\" (statement_list (statement (embedded_statement (simple_embedded_statement \"return\" \";\")))) \"}\")))))) \"}\"))))) <EOF>)",
  )
  @debug.assert_eq(result.diagnostics.map(d => (d.line, d.column)), [])
}

///|
test "CSharp Java 028 compilation_unit" {
  assert_eq(
    @csharp.parse(
      "using System; class C { int F(int x) { return x+1; } }",
      rule="compilation_unit",
    ).context
    .to_tree()
    .to_sexpr(),
    "(compilation_unit (using_directives (using_directive \"using\" (namespace_or_type_name (identifier \"System\")) \";\")) (namespace_member_declarations (namespace_member_declaration (type_declaration (class_definition \"class\" (identifier \"C\") (class_body \"{\" (class_member_declarations (class_member_declaration (common_member_declaration (typed_member_declaration (type_ (base_type (simple_type (numeric_type (integral_type \"int\"))))) (method_declaration (method_member_name (identifier \"F\")) \"(\" (formal_parameter_list (fixed_parameters (fixed_parameter (arg_declaration (type_ (base_type (simple_type (numeric_type (integral_type \"int\"))))) (identifier \"x\"))))) \")\" (method_body (block \"{\" (statement_list (statement (embedded_statement (simple_embedded_statement \"return\" (expression (non_assignment_expression (conditional_expression (null_coalescing_expression (conditional_or_expression (conditional_and_expression (inclusive_or_expression (exclusive_or_expression (and_expression (equality_expression (relational_expression (shift_expression (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (identifier \"x\"))))))) \"+\" (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"1\")))))))))))))))))))) \";\")))) \"}\"))))))) \"}\"))))) <EOF>)",
  )
  let tokens = @csharp.tokenize(
    "using System; class C { int F(int x) { return x+1; } }",
  ).map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel))
  @debug.assert_eq(tokens, [
    (105, "using", 0, 5, 1, 0, 0),
    (7, " ", 5, 6, 1, 5, 1),
    (114, "System", 6, 12, 1, 6, 0),
    (134, ";", 12, 13, 1, 12, 0),
    (7, " ", 13, 14, 1, 13, 1),
    (26, "class", 14, 19, 1, 14, 0),
    (7, " ", 19, 20, 1, 19, 1),
    (114, "C", 20, 21, 1, 20, 0),
    (7, " ", 21, 22, 1, 21, 1),
    (125, "{", 22, 23, 1, 22, 0),
    (7, " ", 23, 24, 1, 23, 1),
    (55, "int", 24, 27, 1, 24, 0),
    (7, " ", 27, 28, 1, 27, 1),
    (114, "F", 28, 29, 1, 28, 0),
    (129, "(", 29, 30, 1, 29, 0),
    (55, "int", 30, 33, 1, 30, 0),
    (7, " ", 33, 34, 1, 33, 1),
    (114, "x", 34, 35, 1, 34, 0),
    (130, ")", 35, 36, 1, 35, 0),
    (7, " ", 36, 37, 1, 36, 1),
    (125, "{", 37, 38, 1, 37, 0),
    (7, " ", 38, 39, 1, 38, 1),
    (82, "return", 39, 45, 1, 39, 0),
    (7, " ", 45, 46, 1, 45, 1),
    (114, "x", 46, 47, 1, 46, 0),
    (135, "+", 47, 48, 1, 47, 0),
    (116, "1", 48, 49, 1, 48, 0),
    (134, ";", 49, 50, 1, 49, 0),
    (7, " ", 50, 51, 1, 50, 1),
    (126, "}", 51, 52, 1, 51, 0),
    (7, " ", 52, 53, 1, 52, 1),
    (126, "}", 53, 54, 1, 53, 0),
    (-1, "<EOF>", 54, 54, 1, 54, 0),
  ])
}

///|
test "CSharp Java recovery 028 compilation_unit" {
  let result = @csharp.parse_recovering(
    "using System; class C { int F(int x) { return x+1; } }",
    rule="compilation_unit",
  )
  assert_eq(
    result.tree.to_sexpr(),
    "(compilation_unit (using_directives (using_directive \"using\" (namespace_or_type_name (identifier \"System\")) \";\")) (namespace_member_declarations (namespace_member_declaration (type_declaration (class_definition \"class\" (identifier \"C\") (class_body \"{\" (class_member_declarations (class_member_declaration (common_member_declaration (typed_member_declaration (type_ (base_type (simple_type (numeric_type (integral_type \"int\"))))) (method_declaration (method_member_name (identifier \"F\")) \"(\" (formal_parameter_list (fixed_parameters (fixed_parameter (arg_declaration (type_ (base_type (simple_type (numeric_type (integral_type \"int\"))))) (identifier \"x\"))))) \")\" (method_body (block \"{\" (statement_list (statement (embedded_statement (simple_embedded_statement \"return\" (expression (non_assignment_expression (conditional_expression (null_coalescing_expression (conditional_or_expression (conditional_and_expression (inclusive_or_expression (exclusive_or_expression (and_expression (equality_expression (relational_expression (shift_expression (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (identifier \"x\"))))))) \"+\" (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"1\")))))))))))))))))))) \";\")))) \"}\"))))))) \"}\"))))) <EOF>)",
  )
  @debug.assert_eq(result.diagnostics.map(d => (d.line, d.column)), [])
}

///|
test "CSharp Java 029 compilation_unit" {
  let rejected = try {
    let _ = @csharp.parse("class C { int x }", rule="compilation_unit")
    false
  } catch {
    @runtime.SyntaxError(_, _, _) => true
    _ => false
  }
  assert_true(rejected)
}

///|
test "CSharp Java recovery 029 compilation_unit" {
  let result = @csharp.parse_recovering(
    "class C { int x }",
    rule="compilation_unit",
  )
  assert_eq(
    result.tree.to_sexpr(),
    "(compilation_unit (namespace_member_declarations (namespace_member_declaration (type_declaration (class_definition \"class\" (identifier \"C\") (class_body \"{\" (class_member_declarations (class_member_declaration (common_member_declaration (typed_member_declaration (type_ (base_type (simple_type (numeric_type (integral_type \"int\")))))))) (class_member_declaration (common_member_declaration)) (class_member_declaration (common_member_declaration (error \"x\")))) \"}\"))))) <EOF>)",
  )
  @debug.assert_eq(result.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(16)),
  ])
}

///|
test "CSharp Java 030 compilation_unit" {
  let rejected = try {
    let _ = @csharp.parse("class C { int x;", rule="compilation_unit")
    false
  } catch {
    @runtime.SyntaxError(_, _, _) => true
    _ => false
  }
  assert_true(rejected)
}

///|
test "CSharp Java recovery 030 compilation_unit" {
  let result = @csharp.parse_recovering(
    "class C { int x;",
    rule="compilation_unit",
  )
  assert_eq(
    result.tree.to_sexpr(),
    "(compilation_unit (namespace_member_declarations (namespace_member_declaration (type_declaration (class_definition \"class\" (identifier \"C\") (class_body \"{\" (class_member_declarations (class_member_declaration (common_member_declaration (typed_member_declaration (type_ (base_type (simple_type (numeric_type (integral_type \"int\"))))) (field_declaration (variable_declarators (variable_declarator (identifier \"x\"))) \";\"))))) (error \"<missing '}'>\")))))) <EOF>)",
  )
  @debug.assert_eq(result.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(16)),
  ])
}

///|
test "CSharp Java 031 compilation_unit" {
  let rejected = try {
    let _ = @csharp.parse(
      "class C { void F() { int x = ; int y=2; } }",
      rule="compilation_unit",
    )
    false
  } catch {
    @runtime.SyntaxError(_, _, _) => true
    _ => false
  }
  assert_true(rejected)
}

///|
test "CSharp Java recovery 031 compilation_unit" {
  let result = @csharp.parse_recovering(
    "class C { void F() { int x = ; int y=2; } }",
    rule="compilation_unit",
  )
  assert_eq(
    result.tree.to_sexpr(),
    "(compilation_unit (namespace_member_declarations (namespace_member_declaration (type_declaration (class_definition \"class\" (identifier \"C\") (class_body \"{\" (class_member_declarations (class_member_declaration (common_member_declaration \"void\" (method_declaration (method_member_name (identifier \"F\")) \"(\" \")\" (method_body (block \"{\" (statement_list (statement (declarationStatement (local_variable_declaration (local_variable_type (type_ (base_type (simple_type (numeric_type (integral_type \"int\")))))) (local_variable_declarator (identifier \"x\") \"=\" (error \";\") (local_variable_initializer (expression (non_assignment_expression (conditional_expression (null_coalescing_expression (conditional_or_expression (conditional_and_expression (inclusive_or_expression (exclusive_or_expression (and_expression (equality_expression (relational_expression (shift_expression (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (predefined_type \"int\"))))))))))))))))))))))) (error \"<missing ';'>\"))) (statement (embedded_statement (simple_embedded_statement (expression (assignment (unary_expression (primary_expression (primary_expression_start (identifier \"y\")))) (assignment_operator \"=\") (expression (non_assignment_expression (conditional_expression (null_coalescing_expression (conditional_or_expression (conditional_and_expression (inclusive_or_expression (exclusive_or_expression (and_expression (equality_expression (relational_expression (shift_expression (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"2\")))))))))))))))))))))) \";\")))) \"}\")))))) \"}\"))))) <EOF>)",
  )
  @debug.assert_eq(result.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(29)),
    (Some(1), Some(35)),
  ])
}

///|
test "CSharp Java 032 compilation_unit" {
  assert_eq(
    @csharp.parse("class C { void F() { return;; } }", rule="compilation_unit").context
    .to_tree()
    .to_sexpr(),
    "(compilation_unit (namespace_member_declarations (namespace_member_declaration (type_declaration (class_definition \"class\" (identifier \"C\") (class_body \"{\" (class_member_declarations (class_member_declaration (common_member_declaration \"void\" (method_declaration (method_member_name (identifier \"F\")) \"(\" \")\" (method_body (block \"{\" (statement_list (statement (embedded_statement (simple_embedded_statement \"return\" \";\"))) (statement (embedded_statement (simple_embedded_statement \";\")))) \"}\")))))) \"}\"))))) <EOF>)",
  )
  let tokens = @csharp.tokenize("class C { void F() { return;; } }").map(t => {
    (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
  })
  @debug.assert_eq(tokens, [
    (26, "class", 0, 5, 1, 0, 0),
    (7, " ", 5, 6, 1, 5, 1),
    (114, "C", 6, 7, 1, 6, 0),
    (7, " ", 7, 8, 1, 7, 1),
    (125, "{", 8, 9, 1, 8, 0),
    (7, " ", 9, 10, 1, 9, 1),
    (108, "void", 10, 14, 1, 10, 0),
    (7, " ", 14, 15, 1, 14, 1),
    (114, "F", 15, 16, 1, 15, 0),
    (129, "(", 16, 17, 1, 16, 0),
    (130, ")", 17, 18, 1, 17, 0),
    (7, " ", 18, 19, 1, 18, 1),
    (125, "{", 19, 20, 1, 19, 0),
    (7, " ", 20, 21, 1, 20, 1),
    (82, "return", 21, 27, 1, 21, 0),
    (134, ";", 27, 28, 1, 27, 0),
    (134, ";", 28, 29, 1, 28, 0),
    (7, " ", 29, 30, 1, 29, 1),
    (126, "}", 30, 31, 1, 30, 0),
    (7, " ", 31, 32, 1, 31, 1),
    (126, "}", 32, 33, 1, 32, 0),
    (-1, "<EOF>", 33, 33, 1, 33, 0),
  ])
}

///|
test "CSharp Java recovery 032 compilation_unit" {
  let result = @csharp.parse_recovering(
    "class C { void F() { return;; } }",
    rule="compilation_unit",
  )
  assert_eq(
    result.tree.to_sexpr(),
    "(compilation_unit (namespace_member_declarations (namespace_member_declaration (type_declaration (class_definition \"class\" (identifier \"C\") (class_body \"{\" (class_member_declarations (class_member_declaration (common_member_declaration \"void\" (method_declaration (method_member_name (identifier \"F\")) \"(\" \")\" (method_body (block \"{\" (statement_list (statement (embedded_statement (simple_embedded_statement \"return\" \";\"))) (statement (embedded_statement (simple_embedded_statement \";\")))) \"}\")))))) \"}\"))))) <EOF>)",
  )
  @debug.assert_eq(result.diagnostics.map(d => (d.line, d.column)), [])
}

///|
test "CSharp Java 033 expression" {
  assert_eq(
    @csharp.parse("x => x+1", rule="expression").context.to_tree().to_sexpr(),
    "(expression (non_assignment_expression (lambda_expression (anonymous_function_signature (identifier \"x\")) (right_arrow \"=\" \">\") (anonymous_function_body (throwable_expression (expression (non_assignment_expression (conditional_expression (null_coalescing_expression (conditional_or_expression (conditional_and_expression (inclusive_or_expression (exclusive_or_expression (and_expression (equality_expression (relational_expression (shift_expression (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (identifier \"x\"))))))) \"+\" (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"1\")))))))))))))))))))))))))",
  )
  let tokens = @csharp.tokenize("x => x+1").map(t => {
    (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
  })
  @debug.assert_eq(tokens, [
    (114, "x", 0, 1, 1, 0, 0),
    (7, " ", 1, 2, 1, 1, 1),
    (145, "=", 2, 3, 1, 2, 0),
    (147, ">", 3, 4, 1, 3, 0),
    (7, " ", 4, 5, 1, 4, 1),
    (114, "x", 5, 6, 1, 5, 0),
    (135, "+", 6, 7, 1, 6, 0),
    (116, "1", 7, 8, 1, 7, 0),
    (-1, "<EOF>", 8, 8, 1, 8, 0),
  ])
}

///|
test "CSharp Java recovery 033 expression" {
  let result = @csharp.parse_recovering("x => x+1", rule="expression")
  assert_eq(
    result.tree.to_sexpr(),
    "(expression (non_assignment_expression (lambda_expression (anonymous_function_signature (identifier \"x\")) (right_arrow \"=\" \">\") (anonymous_function_body (throwable_expression (expression (non_assignment_expression (conditional_expression (null_coalescing_expression (conditional_or_expression (conditional_and_expression (inclusive_or_expression (exclusive_or_expression (and_expression (equality_expression (relational_expression (shift_expression (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (identifier \"x\"))))))) \"+\" (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"1\")))))))))))))))))))))))))",
  )
  @debug.assert_eq(result.diagnostics.map(d => (d.line, d.column)), [])
}

///|
test "CSharp Java 034 expression" {
  let rejected = try {
    let _ = @csharp.parse("x = > x+1", rule="expression")
    false
  } catch {
    @runtime.SyntaxError(_, _, _) => true
    _ => false
  }
  assert_true(rejected)
}

///|
test "CSharp Java recovery 034 expression" {
  let result = @csharp.parse_recovering("x = > x+1", rule="expression")
  assert_eq(
    result.tree.to_sexpr(),
    "(expression (non_assignment_expression (lambda_expression (anonymous_function_signature (identifier \"x\")) (right_arrow \"=\" \">\") (anonymous_function_body (throwable_expression (expression (non_assignment_expression (conditional_expression (null_coalescing_expression (conditional_or_expression (conditional_and_expression (inclusive_or_expression (exclusive_or_expression (and_expression (equality_expression (relational_expression (shift_expression (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (identifier \"x\"))))))) \"+\" (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"1\")))))))))))))))))))))))))",
  )
  @debug.assert_eq(result.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(6)),
  ])
}

///|
test "CSharp Java 035 expression" {
  assert_eq(
    @csharp.parse("x >>= 1", rule="expression").context.to_tree().to_sexpr(),
    "(expression (assignment (unary_expression (primary_expression (primary_expression_start (identifier \"x\")))) (assignment_operator (right_shift_assignment \">\" \">=\")) (expression (non_assignment_expression (conditional_expression (null_coalescing_expression (conditional_or_expression (conditional_and_expression (inclusive_or_expression (exclusive_or_expression (and_expression (equality_expression (relational_expression (shift_expression (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"1\"))))))))))))))))))))))",
  )
  let tokens = @csharp.tokenize("x >>= 1").map(t => {
    (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel)
  })
  @debug.assert_eq(tokens, [
    (114, "x", 0, 1, 1, 0, 0),
    (7, " ", 1, 2, 1, 1, 1),
    (147, ">", 2, 3, 1, 2, 0),
    (159, ">=", 3, 5, 1, 3, 0),
    (7, " ", 5, 6, 1, 5, 1),
    (116, "1", 6, 7, 1, 6, 0),
    (-1, "<EOF>", 7, 7, 1, 7, 0),
  ])
}

///|
test "CSharp Java recovery 035 expression" {
  let result = @csharp.parse_recovering("x >>= 1", rule="expression")
  assert_eq(
    result.tree.to_sexpr(),
    "(expression (assignment (unary_expression (primary_expression (primary_expression_start (identifier \"x\")))) (assignment_operator (right_shift_assignment \">\" \">=\")) (expression (non_assignment_expression (conditional_expression (null_coalescing_expression (conditional_or_expression (conditional_and_expression (inclusive_or_expression (exclusive_or_expression (and_expression (equality_expression (relational_expression (shift_expression (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"1\"))))))))))))))))))))))",
  )
  @debug.assert_eq(result.diagnostics.map(d => (d.line, d.column)), [])
}

///|
test "CSharp Java 036 expression" {
  let rejected = try {
    let _ = @csharp.parse("x > >= 1", rule="expression")
    false
  } catch {
    @runtime.SyntaxError(_, _, _) => true
    _ => false
  }
  assert_true(rejected)
}

///|
test "CSharp Java recovery 036 expression" {
  let result = @csharp.parse_recovering("x > >= 1", rule="expression")
  assert_eq(
    result.tree.to_sexpr(),
    "(expression (assignment (unary_expression (primary_expression (primary_expression_start (identifier \"x\")))) (assignment_operator (right_shift_assignment \">\" \">=\")) (expression (non_assignment_expression (conditional_expression (null_coalescing_expression (conditional_or_expression (conditional_and_expression (inclusive_or_expression (exclusive_or_expression (and_expression (equality_expression (relational_expression (shift_expression (additive_expression (multiplicative_expression (switch_expression (range_expression (unary_expression (primary_expression (primary_expression_start (literal \"1\"))))))))))))))))))))))",
  )
  @debug.assert_eq(result.diagnostics.map(d => (d.line, d.column)), [
    (Some(1), Some(7)),
  ])
}
