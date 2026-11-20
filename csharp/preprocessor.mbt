// Adapted from grammars-v4 csharp/v6/Java/CSharpPreprocessorParserBase.java.
// This file is distributed under EPL-1.0. See LICENSE in this package.

///|
fn boolean(value : Json) -> Bool {
  match value {
    True => true
    _ => false
  }
}

///|
fn conditions(shared : Map[String, Json]) -> Array[Json] {
  match shared.get("conditions") {
    Some(Array(values)) => values.copy()
    _ => [Json::boolean(true)]
  }
}

///|
fn expression_value(frame : @runtime.RuleFrame) -> Bool {
  match frame.values.get("value") {
    Some(String(value)) => value == "true"
    _ => false
  }
}

///|
fn bindings() -> @runtime.RuleSemantics {
  let sources = @preprocessor.parser_action_sources()
  {
    ..@runtime.RuleSemantics::new(),
    action: (event, action) => {
      let source = sources[action]
      let frame = event.frame
      if event.rule == 2 {
        let values = frame.children.map(child => expression_value(child))
        let value = if source.contains("ExpressionTrue") {
          true
        } else if source.contains("ExpressionFalse") {
          false
        } else if source.contains("ExpressionConditionalSymbol") {
          boolean(
            frame.shared
            .get("symbol:" + event.context.text())
            .unwrap_or(Json::boolean(false)),
          )
        } else if source.contains("ExpressionConditionalOpenParens") {
          values[0]
        } else if source.contains("ExpressionConditionalBang") {
          !values[0]
        } else if source.contains("ExpressionConditionalEq") {
          values[0] == values[1]
        } else if source.contains("ExpressionConditionalNe") {
          values[0] != values[1]
        } else if source.contains("ExpressionConditionalAnd") {
          values[0] && values[1]
        } else if source.contains("ExpressionConditionalOr") {
          values[0] || values[1]
        } else {
          false
        }
        frame.values["value"] = Json::string(
          if value {
            "true"
          } else {
            "false"
          },
        )
      } else if event.rule == 0 {
        let stack = conditions(frame.shared)
        let mut value = stack.all(item => boolean(item))
        if source.contains("DirectiveDefine") ||
          source.contains("DirectiveUndef") {
          let symbol = event.context.children[1]
          let token = match symbol {
            @runtime.TokenChild(token) => token
            _ => abort("directive symbol expected")
          }
          frame.shared["symbol:" + token.text] = Json::boolean(
            source.contains("DirectiveDefine"),
          )
        } else if source.contains("DirectiveIf") {
          let condition = expression_value(frame.children[0])
          value = condition && value
          stack.push(Json::boolean(condition))
        } else if source.contains("DirectiveElif") {
          if !boolean(stack.last().unwrap()) {
            ignore(stack.pop())
            let condition = expression_value(frame.children[0])
            value = condition && stack.all(item => boolean(item))
            stack.push(Json::boolean(condition))
          } else {
            value = false
          }
        } else if source.contains("DirectiveElse") {
          if !boolean(stack.last().unwrap()) {
            ignore(stack.pop())
            value = stack.all(item => boolean(item))
            stack.push(Json::boolean(true))
          } else {
            value = false
          }
        } else if source.contains("DirectiveEndif") {
          ignore(stack.pop())
          value = boolean(stack.last().unwrap_or(Json::boolean(false)))
        }
        frame.shared["conditions"] = Json::array(stack)
        frame.values["value"] = Json::boolean(value)
      }
      frame
    },
  }
}

///|
/// Evaluate each directive in order, with isolated state for each source.
pub(all) struct PreprocessorResult {
  tokens : Array[@runtime.Token]
  original_tokens : Array[@runtime.Token]
  directives : Array[Bool]
}

///|
/// Evaluate directives and remove inactive source tokens.
pub fn preprocess(
  source : String,
) -> PreprocessorResult raise @runtime.RuntimeError {
  let tokens = tokenize(source)
  let grammar = @preprocessor.grammar()
  let semantics = bindings()
  let result : Array[Bool] = []
  let output : Array[@runtime.Token] = []
  let mut active = true
  let mut shared = Map([("symbol:DEBUG", Json::boolean(true))])
  let mut offset = 0
  while offset < tokens.length() - 1 {
    if tokens[offset].channel != 3 {
      if active {
        output.push(tokens[offset])
      }
      offset += 1
      continue
    }
    let parsed = grammar.parse_default_tokens(
      tokens[offset:].to_owned(),
      semantics~,
      channel=3,
      shared~,
    )
    if !parsed.diagnostics.is_empty() {
      let diagnostic = parsed.diagnostics[0]
      raise @runtime.SyntaxError(
        diagnostic.line.unwrap_or(1),
        diagnostic.column.unwrap_or(0),
        [],
      )
    }
    let frame = parsed.frame.unwrap()
    active = @preprocessor.CSharpPreprocessorParserPreprocessor_directiveContextAttributes::from_frame(
      frame,
    ).attr_value.unwrap()
    result.push(active)
    shared = frame.shared
    let end = parsed.context.span().unwrap().1
    let previous = offset
    while offset < tokens.length() - 1 && tokens[offset].start < end {
      offset += 1
    }
    if offset == previous {
      raise @runtime.InvalidArgument("directive parser made no progress")
    }
  }
  output.push(tokens.last().unwrap())
  { tokens: output, original_tokens: tokens, directives: result, }
}

///|
pub fn directives(source : String) -> Array[Bool] raise @runtime.RuntimeError {
  preprocess(source).directives
}
