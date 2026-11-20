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
}

///|
/// Hooks return fresh values and must not change external state. The parser
/// explores alternatives with isolated snapshots and exposes only accepted values.
pub(all) struct RuleSemantics {
  enter : (Int32, RuleFrame) -> RuleFrame
  arguments : (SemanticEvent, Int32) -> Map[String, Json]
  action : (SemanticEvent, Int32) -> RuleFrame
  predicate : (SemanticEvent, Int32) -> Bool
}

///|
pub fn RuleSemantics::new() -> RuleSemantics {
  {
    enter: (_, frame) => frame,
    arguments: (_, _) => Map([]),
    action: (event, _) => event.frame,
    predicate: (_, _) => true,
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
