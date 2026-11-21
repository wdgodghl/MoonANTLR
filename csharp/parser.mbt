// Adapted from grammars-v4 CSharpParserBase.java and inline predicates.
// Distributed under EPL-1.0. See LICENSE in this package.

///|
fn syntax_bindings() -> @runtime.RuleSemantics {
  {
    ..@runtime.RuleSemantics::new(),
    predicate: (event, _) => {
      match event.context.name {
        "local_variable_declaration" => {
          let types = event.context.rules("local_variable_type")
          types.is_empty() || types[0].text() != "var"
        }
        "right_arrow" | "right_shift" | "right_shift_assignment" => {
          let matched : Array[@runtime.Token] = []
          for child in event.context.children {
            if child is @runtime.TokenChild(token) {
              matched.push(token)
            }
          }
          if matched.length() < 2 {
            false
          } else {
            let mut first = -2
            let mut second = -1
            for index, token in event.tokens {
              if token == matched[0] {
                first = index
              }
              if token == matched[1] {
                second = index
              }
            }
            first >= 0 && second == first + 1
          }
        }
        _ => false
      }
    },
  }
}

///|
/// Parse one original C# rule, with the ported contextual predicates.
pub fn parse(
  source : String,
  rule~ : String = "compilation_unit",
  work_limit~ : Int32 = 1_000_000,
) -> @runtime.ParseResult raise @runtime.RuntimeError {
  let recovered = parse_recovering(source, rule~, work_limit~)
  if !recovered.diagnostics.is_empty() {
    let diagnostic = recovered.diagnostics[0]
    raise @runtime.SyntaxError(
      diagnostic.line.unwrap_or(1),
      diagnostic.column.unwrap_or(0),
      [],
    )
  }
  if recovered.next_token.kind != -1 {
    raise @runtime.SyntaxError(
      recovered.next_token.line,
      recovered.next_token.column,
      [-1],
    )
  }
  {
    context: recovered.context,
    frame: recovered.frame,
    prediction: recovered.prediction,
  }
}

///|
/// Parse with contextual predicates, committed host actions and recovery nodes.
pub fn parse_recovering(
  source : String,
  rule~ : String = "compilation_unit",
  work_limit~ : Int32 = 1_000_000,
) -> @runtime.DefaultParseResult raise @runtime.RuntimeError {
  let grammar = @syntax.grammar()
  let mut start = -1
  for index, name in grammar.rules {
    if name == rule {
      start = index
    }
  }
  if start < 0 {
    raise @runtime.InvalidArgument("unknown C# rule: " + rule)
  }
  let prepared = preprocess(source, recover_lexer=true)
  let parsed = grammar.parse_default_tokens(
    prepared.tokens,
    semantics=syntax_bindings(),
    start_rule=start,
    work_limit~,
    original_tokens=prepared.original_tokens,
  )
  let diagnostics = prepared.lexical_errors.map(error => {
    error.diagnostic(grammar)
  })
  for diagnostic in parsed.diagnostics {
    diagnostics.push(diagnostic)
  }
  { ..parsed, diagnostics, }
}
