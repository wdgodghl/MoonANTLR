///|
test "ported preprocessor attributes and shared condition state match the Java baseline" {
  @debug.assert_eq(
    @csharp.directives(
      "#define FEATURE\n#if FEATURE && !false\n#else\n#endif\n",
    ),
    [true, true, false, true],
  )
}

///|
test "ported interpolated string mode state matches the Java baseline" {
  let tokens = @csharp.tokenize("$\"value={1+2}\"")
  @debug.assert_eq(tokens.map(token => token.text), [
    "$\"", "value=", "1", "+", "2", "\"", "<EOF>",
  ])
}

///|
test "ported CSharp contextual and token index predicates match Java" {
  let _ = @csharp.parse("8 >> 1", rule="expression")
  let _ = @csharp.parse("int x=1,y=2;", rule="declarationStatement")
  for
    (source, rule) in [
      ("8 > > 1", "expression"),
      ("var x=1,y=2;", "declarationStatement"),
    ] {
    let rejected = try {
      let _ = @csharp.parse(source, rule~)
      false
    } catch {
      @runtime.SyntaxError(_, _, _) => true
      _ => false
    }
    assert_true(rejected, msg=source)
  }
}

///|
test "conditional compilation excludes inactive source and isolates files" {
  let source = "#if false\nthis is invalid CSharp;\n#else\nclass C {}\n#endif\n"
  let parsed = @csharp.parse(source)
  assert_true(parsed.context.text().contains("classC{}"))
  assert_false(parsed.context.text().contains("invalid"))
  @debug.assert_eq(@csharp.directives("#define X\n#if X\n#endif\n"), [
    true, true, true,
  ])
  @debug.assert_eq(@csharp.directives("#if X\n#else\n#endif\n"), [
    false, true, true,
  ])
}
