// Adapted from grammars-v4 csharp/v6/Java/CSharpLexerBase.java.
// This file is distributed under EPL-1.0. See LICENSE in this package.

///|
priv struct StringState {
  strings : Array[Bool]
  braces : Array[Int32]
  mut verbatim : Bool
}

///|
/// Tokenize using the unchanged upstream C# grammar and ported host methods.
fn lex(
  source : String,
  recover : Bool,
  trace : Array[Json]?,
) -> @runtime.LexResult raise @runtime.RuntimeError {
  let state : StringState = { strings: [], braces: [], verbatim: false, }
  let names = @syntax.lexer_rule_names()
  let cursor = @runtime.deserialize(@syntax.lexer_data()).lexer_cursor(
    source,
    recover~,
    lexer_predicate=(rule, _, _, _) => {
      match names[rule] {
        "REGULAR_CHAR_INSIDE" | "REGULAR_STRING_INSIDE" => !state.verbatim
        "VERBATIUM_DOUBLE_QUOTE_INSIDE" | "VERBATIUM_INSIDE_STRING" =>
          state.verbatim
        _ => false
      }
    },
    lexer_action=(event, input) => {
      match names[event.rule] {
        "INTERPOLATED_REGULAR_STRING_START"
        | "INTERPOLATED_VERBATIUM_STRING_START" => {
          state.verbatim = names[event.rule] ==
            "INTERPOLATED_VERBATIUM_STRING_START"
          state.strings.push(state.verbatim)
        }
        "OPEN_BRACE" =>
          if !state.strings.is_empty() {
            if state.braces.pop() is Some(count) {
              state.braces.push(count + 1)
            } else {
              raise @runtime.LexicalError(
                1,
                event.offset,
                "missing interpolation brace",
              )
            }
          }
        "CLOSE_BRACE" =>
          if !state.strings.is_empty() {
            let count = state.braces.pop().unwrap_or(0) - 1
            if count == 0 {
              event.emission = @runtime.Skip
              event.pop_mode()
            } else if count > 0 {
              state.braces.push(count)
            } else {
              raise @runtime.LexicalError(
                1,
                event.offset,
                "missing interpolation brace",
              )
            }
          }
        "COLON" =>
          if !state.strings.is_empty() {
            let chars = input.to_array()
            let mut index = event.offset
            let mut format = true
            while index < chars.length() && chars[index] != '}' {
              if chars[index] == ':' || chars[index] == ')' {
                format = false
                break
              }
              index += 1
            }
            if format {
              event.set_mode(2)
            }
          }
        "OPEN_BRACE_INSIDE" => state.braces.push(1)
        "DOUBLE_QUOTE_INSIDE" => {
          ignore(state.strings.pop())
          state.verbatim = state.strings.last().unwrap_or(false)
        }
        "CLOSE_BRACE_INSIDE" => ignore(state.braces.pop())
        _ => ()
      }
      if trace is Some(events) {
        let helper_name = match names[event.rule] {
          "INTERPOLATED_REGULAR_STRING_START" =>
            "OnInterpolatedRegularStringStart"
          "INTERPOLATED_VERBATIUM_STRING_START" =>
            "OnInterpolatedVerbatiumStringStart"
          "OPEN_BRACE" => "OnOpenBrace"
          "CLOSE_BRACE" => "OnCloseBrace"
          "COLON" => "OnColon"
          "OPEN_BRACE_INSIDE" => "OpenBraceInside"
          "DOUBLE_QUOTE_INSIDE" => "OnDoubleQuoteInside"
          "CLOSE_BRACE_INSIDE" => "OnCloseBraceInside"
          _ => "unknown"
        }
        events.push({
          "method": Json::string(helper_name),
          "offset": Json::number(event.offset.to_double()),
          "strings": Json::array(
            state.strings.map(value => Json::boolean(value)),
          ),
          "braces": Json::array(
            state.braces.map(value => Json::number(value.to_double())),
          ),
          "mode": Json::number(event.mode.to_double()),
        })
      }
    },
  )
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  { tokens, errors: cursor.diagnostics(), }
}

///|
pub fn tokenize(
  source : String,
) -> Array[@runtime.Token] raise @runtime.RuntimeError {
  lex(source, false, None).tokens
}

///|
pub fn tokenize_recovering(
  source : String,
) -> @runtime.LexResult raise @runtime.RuntimeError {
  lex(source, true, None)
}

///|
pub(all) struct LexerTraceResult {
  result : @runtime.LexResult
  events : Array[Json]
}

///|
pub fn tokenize_traced(
  source : String,
  recover~ : Bool = false,
) -> LexerTraceResult raise @runtime.RuntimeError {
  let events : Array[Json] = []
  { result: lex(source, recover, Some(events)), events, }
}
