// Adapted from ANTLR 4.13.2 Java.test.stg PositionAdjustingLexer.
// BSD-3-Clause: upstream/LICENSE.

///|
fn position_adjusted_tokens(
  data : Array[Int32],
  source : String,
  keyword : Int32,
  label : Int32,
) -> @runtime.LexResult raise @runtime.RuntimeError {
  let cursor = @runtime.deserialize(data).lexer_cursor(source, recover=true)
  let tokens : Array[@runtime.Token] = []
  while true {
    let token = cursor.next_token()
    let token = if token.kind == keyword || token.kind == label {
      let chars = token.text.to_array()
      let mut length = if token.kind == keyword { 6 } else { 0 }
      if token.kind == label {
        while length < chars.length() {
          let c = chars[length]
          if (c >= 'a' && c <= 'z') ||
            (c >= 'A' && c <= 'Z') ||
            (c >= '0' && c <= '9') ||
            c == '_' {
            length += 1
          } else {
            break
          }
        }
      }
      cursor.seek(token.start + length)
      {
        ..token,
        text: String::from_array(chars[:length]),
        end: token.start + length,
      }
    } else {
      token
    }
    tokens.push(token)
    if token.kind == -1 {
      break
    }
  }
  { tokens, errors: cursor.diagnostics(), }
}
