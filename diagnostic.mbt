///|
/// Stable, serializable diagnostics for editor and CLI consumers.
pub(all) struct Diagnostic {
  code : String
  message : String
  line : Int32?
  column : Int32?
  expected : Array[String]
} derive(Debug, Eq, ToJson)

///|
pub extend Diagnostic with @debug.Debug::{to_repr}

///|
pub extend Diagnostic with Eq::{equal, not_equal}

///|
pub extend Diagnostic with ToJson::{to_json}

///|
/// ANTLR display names prefer literal names, then symbolic names.
pub fn Grammar::token_name(self : Grammar, kind : Int32) -> String {
  if kind == -1 {
    return "EOF"
  }
  if kind >= 0 && kind < self.vocabulary.length() {
    return self.vocabulary[kind]
  }
  kind.to_string()
}

///|
/// Convert a typed runtime failure without discarding its source location.
pub fn RuntimeError::diagnostic(
  self : RuntimeError,
  grammar : Grammar,
) -> Diagnostic {
  match self {
    InvalidArgument(message) =>
      {
        code: "invalid_argument",
        message,
        line: None,
        column: None,
        expected: [],
      }
    InvalidAtn(message) =>
      { code: "invalid_atn", message, line: None, column: None, expected: [], }
    Unsupported(message) =>
      { code: "unsupported", message, line: None, column: None, expected: [], }
    LimitExceeded(message) =>
      {
        code: "limit_exceeded",
        message,
        line: None,
        column: None,
        expected: [],
      }
    LexicalError(line, column, message) =>
      {
        code: "lexical_error",
        message,
        line: Some(line),
        column: Some(column),
        expected: [],
      }
    SyntaxError(line, column, expected) => {
      let names = expected.map(kind => grammar.token_name(kind))
      let out = StringBuilder()
      out.write_string("unexpected input; expected ")
      for i in 0..<names.length() {
        if i > 0 {
          out.write_string(", ")
        }
        out.write_string(names[i])
      }
      {
        code: "syntax_error",
        message: out.to_string(),
        line: Some(line),
        column: Some(column),
        expected: names,
      }
    }
  }
}
