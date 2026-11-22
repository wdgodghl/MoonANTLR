///|
pub(all) struct RecoveryResult {
  context : RuleContext?
  diagnostics : Array[Diagnostic]
  complete : Bool
  repairs : Array[RecoveryEdit]
}

///|
/// A committed repair with original Token positions.
pub(all) enum RecoveryEdit {
  Inserted(Token)
  Deleted(Token)
  Synchronized(Array[Token])
}

///|
priv enum RecoveryAttempt {
  Parsed(RuleContext)
  Rejected(RuntimeError, RuleContext?)
}

///|
fn Grammar::try_tokens(
  self : Grammar,
  tokens : Array[Token],
  start_rule : Int32,
  budget : Budget,
  predicate : ParserPredicate?,
) -> RecoveryAttempt raise RuntimeError {
  let prefix = Ref(None)
  let result = self.parse_tokens(tokens, start_rule, budget, predicate, prefix~) catch {
    SyntaxError(_, _, _) as error => return Rejected(error, prefix.val)
    error => raise error
  }
  Parsed(result.parsed.context)
}

///|
/// Retry syntax errors using bounded token edits. Synchronization token kinds
/// are supplied by the caller. Opt in to lexer recovery with recover_lexer.
pub fn Grammar::parse_recovering(
  self : Grammar,
  source : String,
  start_rule~ : Int32 = 0,
  sync_tokens~ : Array[Int32] = [],
  max_repairs~ : Int32 = 8,
  work_limit~ : Int32 = 1_000_000,
  predicate? : ParserPredicate,
  lexer_predicate? : LexerPredicate,
  lexer_context_predicate? : LexerContextPredicate,
  lexer_action? : LexerAction,
  recover_lexer~ : Bool = false,
) -> RecoveryResult raise RuntimeError {
  let budget : Budget = { remaining: work_limit, }
  let diagnostics : Array[Diagnostic] = []
  let repairs : Array[RecoveryEdit] = []
  let emitted = if recover_lexer {
    let lexed = self.tokenize_recovering(
      source,
      work_limit~,
      lexer_predicate?,
      lexer_context_predicate?,
      lexer_action?,
    )
    for error in lexed.errors {
      diagnostics.push(error.diagnostic(self))
    }
    lexed.tokens
  } else {
    self.tokenize(
      source,
      work_limit~,
      lexer_predicate?,
      lexer_context_predicate?,
      lexer_action?,
    )
  }
  let mut tokens = TokenStream::new(emitted).visible_tokens()
  let mut attempt = self.try_tokens(tokens, start_rule, budget, predicate)
  for repair in 0..<=max_repairs.max(0) {
    match attempt {
      Parsed(context) =>
        return { context: Some(context), diagnostics, repairs, complete: true, }
      Rejected(SyntaxError(line, column, expected) as error, prefix) => {
        diagnostics.push(error.diagnostic(self))
        if repair >= max_repairs {
          return { context: prefix, diagnostics, repairs, complete: false, }
        }
        let mut index = 0
        while index + 1 < tokens.length() &&
              (tokens[index].line != line || tokens[index].column != column) {
          index += 1
        }
        let here = tokens[index]
        let edits : Array[(Int32, RecoveryEdit)] = []
        // At a narrow decision prefer preserving the next source token.
        // At a broad decision prefer removal to inventing a missing value.
        if here.kind != -1 && expected.length() > 2 {
          edits.push((index + 1, Deleted(here)))
        }
        for kind in expected {
          if kind > 0 {
            edits.push(
              (index, Inserted({ ..here, kind, text: "", end: here.start, })),
            )
          }
        }
        if here.kind != -1 && expected.length() <= 2 {
          edits.push((index + 1, Deleted(here)))
        }
        for end in (index + 1)..<tokens.length() {
          if sync_tokens.contains(tokens[end].kind) {
            edits.push((end, Synchronized(tokens[index:end].to_owned())))
            if tokens[end].kind != -1 {
              edits.push(
                (end + 1, Synchronized(tokens[index:end + 1].to_owned())),
              )
            }
            break
          }
        }
        let mut best = (line, column)
        let mut next : (Array[Token], RecoveryAttempt, RecoveryEdit)? = None
        for (end, edit) in edits {
          budget.tick()
          let candidate = tokens[:index].to_owned()
          if edit is Inserted(token) {
            candidate.push(token)
          }
          for i in end..<tokens.length() {
            candidate.push(tokens[i])
          }
          let tried = self.try_tokens(candidate, start_rule, budget, predicate)
          match tried {
            Parsed(context) => {
              repairs.push(edit)
              return {
                context: Some(context),
                diagnostics,
                repairs,
                complete: true,
              }
            }
            Rejected(SyntaxError(row, col, _), _) =>
              if row > best.0 || (row == best.0 && col > best.1) {
                best = (row, col)
                next = Some((candidate, tried, edit))
              }
            _ => ()
          }
        }
        if next is Some((candidate, tried, edit)) {
          repairs.push(edit)
          tokens = candidate
          attempt = tried
        } else {
          return { context: prefix, diagnostics, repairs, complete: false, }
        }
      }
      Rejected(error, _) => raise error
    }
  } nobreak {
    { context: None, diagnostics, repairs, complete: false, }
  }
}
