///|
pub(all) struct RecoveryResult {
  context : RuleContext?
  diagnostics : Array[Diagnostic]
  complete : Bool
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
  Parsed(result.context)
}

///|
/// Retry syntax errors using bounded token edits. Synchronization token kinds
/// are supplied by the caller. Lexical and resource errors still raise.
pub fn Grammar::parse_recovering(
  self : Grammar,
  source : String,
  start_rule~ : Int32 = 0,
  sync_tokens~ : Array[Int32] = [],
  max_repairs~ : Int32 = 8,
  work_limit~ : Int32 = 1_000_000,
  predicate? : ParserPredicate,
) -> RecoveryResult raise RuntimeError {
  let mut tokens = TokenStream::new(self.tokenize(source, work_limit~)).visible_tokens()
  let budget : Budget = { remaining: work_limit, }
  let diagnostics : Array[Diagnostic] = []
  let mut attempt = self.try_tokens(tokens, start_rule, budget, predicate)
  for repair in 0..<=max_repairs.max(0) {
    match attempt {
      Parsed(context) =>
        return { context: Some(context), diagnostics, complete: true, }
      Rejected(SyntaxError(line, column, expected) as error, prefix) => {
        diagnostics.push(error.diagnostic(self))
        if repair >= max_repairs {
          return { context: prefix, diagnostics, complete: false, }
        }
        let mut index = 0
        while index + 1 < tokens.length() &&
              (tokens[index].line != line || tokens[index].column != column) {
          index += 1
        }
        let here = tokens[index]
        let edits : Array[(Int32, Token?)] = []
        // At a narrow decision prefer preserving the next source token.
        // At a broad decision prefer removal to inventing a missing value.
        if here.kind != -1 && expected.length() > 2 {
          edits.push((index + 1, None))
        }
        for kind in expected {
          if kind > 0 {
            edits.push(
              (index, Some({ ..here, kind, text: "", end: here.start, })),
            )
          }
        }
        if here.kind != -1 && expected.length() <= 2 {
          edits.push((index + 1, None))
        }
        for end in (index + 1)..<tokens.length() {
          if sync_tokens.contains(tokens[end].kind) {
            edits.push((end, None))
            if tokens[end].kind != -1 {
              edits.push((end + 1, None))
            }
            break
          }
        }
        let mut best = (line, column)
        let mut next : (Array[Token], RecoveryAttempt)? = None
        for (end, inserted) in edits {
          budget.tick()
          let candidate = tokens[:index].to_owned()
          if inserted is Some(token) {
            candidate.push(token)
          }
          for i in end..<tokens.length() {
            candidate.push(tokens[i])
          }
          let tried = self.try_tokens(candidate, start_rule, budget, predicate)
          match tried {
            Parsed(context) =>
              return { context: Some(context), diagnostics, complete: true, }
            Rejected(SyntaxError(row, col, _), _) =>
              if row > best.0 || (row == best.0 && col > best.1) {
                best = (row, col)
                next = Some((candidate, tried))
              }
            _ => ()
          }
        }
        if next is Some((candidate, tried)) {
          tokens = candidate
          attempt = tried
        } else {
          return { context: prefix, diagnostics, complete: false, }
        }
      }
      Rejected(error, _) => raise error
    }
  } nobreak {
    { context: None, diagnostics, complete: false, }
  }
}
