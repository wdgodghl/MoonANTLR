///|
/// A parse-local channel buffer; prediction may request additional tokens.
priv struct ParserInput {
  visible : Array[Token]
  original : Array[Token]
  lexer : LexerCursor?
}

///|
fn ParserInput::token(
  self : ParserInput,
  index : Int32,
) -> Token raise RuntimeError {
  while index >= self.visible.length() {
    if self.visible.last() is Some(token) && token.kind == -1 {
      return token
    }
    guard self.lexer is Some(lexer) else {
      raise InvalidArgument("parser token buffer must end in EOF")
    }
    let token = lexer.next_token()
    self.original.push(token)
    if token.channel == 0 || token.kind == -1 {
      self.visible.push(token)
    }
  }
  self.visible[index]
}

///|
/// Invoke a rule using demand-driven lexing. Unrequested source remains unread.
pub fn Grammar::parse_prefix_lazy(
  self : Grammar,
  source : String,
  start_rule~ : Int32 = 0,
  work_limit~ : Int32 = 1_000_000,
  lexer_predicate? : LexerPredicate,
  lexer_action? : LexerAction,
  parser_action? : ParserAction,
) -> PrefixResult raise RuntimeError {
  let lexer = self.lexer_cursor(
    source,
    work_limit~,
    lexer_predicate?,
    lexer_action?,
  )
  self.parse_tokens(
    [],
    start_rule,
    { remaining: work_limit, },
    None,
    complete=false,
    parser_action?,
    cursor=lexer,
  )
}
