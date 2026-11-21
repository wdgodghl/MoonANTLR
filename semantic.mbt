///|
/// Values belong to one rule invocation. Shared values flow through calls.
pub(all) struct RuleFrame {
  values : Map[String, Json]
  shared : Map[String, Json]
  children : Array[RuleFrame]
}

///|
pub(all) struct SemanticEvent {
  rule : Int32
  site : Int32
  context : RuleContext
  next_token : Token
  frame : RuleFrame
  tokens : Array[Token]
  lookahead_fn : (Int32) -> Token raise RuntimeError
}

///|
/// Snapshot parsing requires pure hooks and exposes only accepted values.
/// Default parsing commits actions once; its action hooks may update external
/// state. Predicate hooks must remain side-effect-free in both entry points.
pub(all) struct RuleSemantics {
  enter : (Int32, RuleFrame) -> RuleFrame
  /// Construct a fresh attribute scope when left recursion wraps its left child.
  wrap : (Int32, RuleFrame) -> RuleFrame
  arguments : (SemanticEvent, Int32) -> Map[String, Json]
  action : (SemanticEvent, Int32) -> RuleFrame raise RuntimeError
  predicate : (SemanticEvent, Int32) -> Bool raise RuntimeError
}

///|
/// One-based visible lookahead, fetching from the Lexer only when requested.
pub fn SemanticEvent::lookahead(
  self : SemanticEvent,
  offset : Int32,
) -> Token raise RuntimeError {
  if offset < 1 {
    raise InvalidArgument("lookahead is one-based")
  }
  (self.lookahead_fn)(offset)
}

///|
pub fn RuleSemantics::new() -> RuleSemantics {
  {
    enter: (_, frame) => frame,
    wrap: (_, previous) => {
      values: Map([]),
      shared: previous.shared.copy(),
      children: [previous],
    },
    arguments: (_, _) => Map([]),
    action: (event, _) => event.frame,
    predicate: (_, _) => true,
  }
}

///|
/// Checked accessors for generated attribute records.
pub fn RuleFrame::int_value(
  self : RuleFrame,
  name : String,
) -> Int32? raise RuntimeError {
  match self.values.get(name) {
    None => None
    Some(Number(value, ..)) =>
      if value >= -2147483648.0 &&
        value <= 2147483647.0 &&
        value.to_int().to_double() == value {
        Some(value.to_int())
      } else {
        raise InvalidArgument("integer attribute out of range: " + name)
      }
    _ => raise InvalidArgument("integer attribute expected: " + name)
  }
}

///|
pub fn RuleFrame::bool_value(
  self : RuleFrame,
  name : String,
) -> Bool? raise RuntimeError {
  match self.values.get(name) {
    None => None
    Some(True) => Some(true)
    Some(False) => Some(false)
    _ => raise InvalidArgument("boolean attribute expected: " + name)
  }
}

///|
pub fn RuleFrame::string_value(
  self : RuleFrame,
  name : String,
) -> String? raise RuntimeError {
  match self.values.get(name) {
    None => None
    Some(String(value)) => Some(value)
    _ => raise InvalidArgument("string attribute expected: " + name)
  }
}

///|
pub fn RuleFrame::double_value(
  self : RuleFrame,
  name : String,
) -> Double? raise RuntimeError {
  match self.values.get(name) {
    None => None
    Some(Number(value, ..)) => Some(value)
    _ => raise InvalidArgument("numeric attribute expected: " + name)
  }
}

///|
fn RuleFrame::snapshot(self : RuleFrame) -> RuleFrame {
  {
    values: self.values.copy(),
    shared: self.shared.copy(),
    children: self.children.copy(),
  }
}

///|
/// Execute attribute, action and contextual predicate bindings during parsing.
pub fn Grammar::parse_semantic(
  self : Grammar,
  source : String,
  semantics : RuleSemantics,
  arguments~ : Map[String, Json] = Map([]),
  shared~ : Map[String, Json] = Map([]),
  start_rule~ : Int32 = 0,
  work_limit~ : Int32 = 1_000_000,
  lexer_predicate? : LexerPredicate,
  lexer_action? : LexerAction,
) -> ParseResult raise RuntimeError {
  let tokens = TokenStream::new(
    self.tokenize(source, work_limit~, lexer_predicate?, lexer_action?),
  ).visible_tokens()
  self.parse_tokens(
    tokens,
    start_rule,
    { remaining: work_limit, },
    None,
    semantics~,
    initial_frame={
      values: arguments.copy(),
      shared: shared.copy(),
      children: [],
    },
  ).parsed
}

///|
/// Parse an already-tokenized channel, retaining the original buffer for predicates.
pub fn Grammar::parse_semantic_tokens(
  self : Grammar,
  tokens : Array[Token],
  semantics : RuleSemantics,
  channel~ : Int32 = 0,
  start_rule~ : Int32 = 0,
  arguments~ : Map[String, Json] = Map([]),
  shared~ : Map[String, Json] = Map([]),
  complete~ : Bool = true,
  work_limit~ : Int32 = 1_000_000,
  original_tokens? : Array[Token],
) -> PrefixResult raise RuntimeError {
  let visible = TokenStream::new(tokens, channel~).visible_tokens()
  self.parse_tokens(
    visible,
    start_rule,
    { remaining: work_limit, },
    None,
    semantics~,
    complete~,
    source_tokens=original_tokens.unwrap_or(tokens),
    initial_frame={
      values: arguments.copy(),
      shared: shared.copy(),
      children: [],
    },
  )
}
