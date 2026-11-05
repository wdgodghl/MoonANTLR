///|
/// Errors are explicit: unsupported ATN features never silently change meaning.
pub(all) suberror RuntimeError {
  InvalidAtn(String)
  Unsupported(String)
  LexicalError(Int32, Int32, String)
  SyntaxError(Int32, Int32, Array[Int32])
  LimitExceeded(String)
} derive(Debug)

///|
/// ANTLR serialized transition fields, preserved without target-specific encoding.
priv struct Edge {
  target : Int32
  kind : Int32
  a : Int32
  b : Int32
  c : Int32
}

///|
struct State {
  kind : Int32
  rule : Int32
  mut non_greedy : Bool
  edges : Array[Edge]
}

///|
/// Serialized ATN v4. Treat the graph as immutable after deserialization.
pub struct Atn {
  kind : Int32
  max_token : Int32
  states : Array[State]
  starts : Array[Int32]
  token_types : Array[Int32]
  modes : Array[Int32]
  sets : Array[Array[(Int32, Int32)]]
  actions : Array[(Int32, Int32, Int32)]
}

///|
/// Source offsets and columns count Unicode scalar values; end is exclusive.
pub(all) struct Token {
  kind : Int32
  text : String
  start : Int32
  end : Int32
  line : Int32
  column : Int32
  channel : Int32
} derive(Debug, Eq)

///|
pub(all) enum ParseTree {
  Terminal(Token)
  Rule(String, Array[ParseTree])
} derive(Debug, Eq)

///|
pub fn ParseTree::to_sexpr(self : ParseTree) -> String {
  match self {
    Terminal(token) =>
      if token.kind == -1 {
        "<EOF>"
      } else {
        token.text.escape()
      }
    Rule(name, children) => {
      let out = StringBuilder()
      out.write_string("(" + name)
      for child in children {
        out.write_string(" ")
        out.write_string(child.to_sexpr())
      }
      out.write_string(")")
      out.to_string()
    }
  }
}

///|
/// A portable, generated lexer/parser pair with upstream rule names.
pub(all) struct Grammar {
  lexer : Atn
  parser : Atn
  rules : Array[String]
}

///|
pub extend RuntimeError with @debug.Debug::{to_repr}

///|
pub extend Token with @debug.Debug::{to_repr}

///|
pub extend Token with Eq::{equal, not_equal}

///|
pub extend ParseTree with @debug.Debug::{to_repr}

///|
pub extend ParseTree with Eq::{equal, not_equal}

///|
