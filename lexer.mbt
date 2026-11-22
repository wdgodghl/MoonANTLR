///|
/// A pure Lexer predicate. Offsets are Unicode scalar indices in source.
pub type LexerPredicate = (Int32, Int32, Int32, String) -> Bool

///|
pub(all) struct LexerPredicateEvent {
  rule : Int32
  predicate : Int32
  token_start : Int32
  token_line : Int32
  token_column : Int32
  offset : Int32
  line : Int32
  column : Int32
  text : String
  source : String
}

///|
pub type LexerContextPredicate = (LexerPredicateEvent) -> Bool

///|
struct Budget {
  mut remaining : Int32
}

///|
fn Budget::tick(self : Budget) -> Unit raise RuntimeError {
  if self.remaining <= 0 {
    raise LimitExceeded("ATN work budget exhausted")
  }
  self.remaining -= 1
}

///|
pub(all) struct LexerActionEvent {
  rule : Int32
  action : Int32
  token_start : Int32
  offset : Int32
  token_end : Int32
  mut emission : LexerEmission
  mut channel : Int32
  mut text : String?
  mut mode : Int32
  mut mode_stack : Array[Int32]
}

///|
/// Switch the current mode, preserving the return-mode stack.
pub fn LexerActionEvent::set_mode(
  self : LexerActionEvent,
  mode : Int32,
) -> Unit {
  self.mode = mode
}

///|
pub fn LexerActionEvent::push_mode(
  self : LexerActionEvent,
  mode : Int32,
) -> Unit {
  self.mode_stack.push(self.mode)
  self.mode = mode
}

///|
pub fn LexerActionEvent::pop_mode(
  self : LexerActionEvent,
) -> Unit raise RuntimeError {
  self.mode = match self.mode_stack.pop() {
    Some(mode) => mode
    None => raise InvalidArgument("lexer mode stack underflow")
  }
}

///|
pub(all) enum LexerEmission {
  Emit(Int32)
  Skip
  More
}

///|
/// Executes after the winning path has been selected.
pub type LexerAction = (LexerActionEvent, String) -> Unit raise RuntimeError

///|
pub(all) struct LexResult {
  tokens : Array[Token]
  errors : Array[RuntimeError]
}

///|
priv struct LexConfig {
  state : Int32
  pos : Int32
  root : Int32
  returns : Array[Int32]
  actions : Array[(Int32, Int32)]
  passed_non_greedy : Bool
  matched_eof : Bool
}

///|
fn LexConfig::key(self : LexConfig) -> String {
  let out = StringBuilder()
  out.write_string(
    self.state.to_string() +
    ":" +
    self.pos.to_string() +
    ":" +
    self.root.to_string(),
  )
  if self.matched_eof {
    out.write_string("$")
  }
  if self.passed_non_greedy {
    out.write_string("!")
  }
  for n in self.returns {
    out.write_string("/" + n.to_string())
  }
  out.write_string(":")
  for n in self.actions {
    out.write_string("/" + n.0.to_string() + "@" + n.1.to_string())
  }
  out.to_string()
}

///|
/// Ordered NFA execution. A rule acceptance suppresses lower-priority paths
/// that passed a non-greedy decision. Competing rules still prefer longest match.
fn lex_match(
  atn : Atn,
  chars : Array[Char],
  start : Int32,
  mode : Int32,
  budget : Budget,
  source : String,
  predicate : LexerPredicate?,
  context_predicate : LexerContextPredicate?,
  token_start : Int32,
  trace : LexerDfa?,
) -> (LexConfig?, Int32) raise RuntimeError {
  if mode < 0 || mode >= atn.modes.length() {
    raise InvalidAtn("unknown lexer mode")
  }
  let work : Array[LexConfig] = []
  let entries = atn.states[atn.modes[mode]].edges
  for i = entries.length() - 1; i >= 0; i = i - 1 {
    let edge = entries[i]
    if edge.kind != 1 {
      raise InvalidAtn("mode must enter rules through epsilon edges")
    }
    if atn.states[edge.target].kind != 2 {
      raise InvalidAtn("mode must enter a rule start")
    }
    work.push({
      state: edge.target,
      pos: start,
      root: atn.states[edge.target].rule,
      returns: [],
      actions: [],
      passed_non_greedy: false,
      matched_eof: false,
    })
  }
  let seen : Map[String, Bool] = Map([])
  let mut best : LexConfig? = None
  let mut farthest = start
  let mut next : Array[LexConfig] = []
  let accepted : Map[Int32, Bool] = Map([])
  let mut observed : Array[LexConfig] = []
  let mut semantic = false
  let mut previous : Int32? = None
  let mut position = start
  while !work.is_empty() || !next.is_empty() {
    if work.is_empty() {
      if trace is Some(trace) {
        previous = trace.record(
          observed, atn, start, position, previous, semantic, chars,
        )
      }
      observed = []
      semantic = false
      position += 1
      for i = next.length() - 1; i >= 0; i = i - 1 {
        work.push(next[i])
      }
      next = []
      accepted.clear()
      seen.clear()
    }
    budget.tick()
    let cfg = work.pop().unwrap()
    farthest = farthest.max(cfg.pos)
    let state = atn.states[cfg.state]
    let cfg = {
      ..cfg,
      passed_non_greedy: cfg.passed_non_greedy || state.non_greedy,
    }
    if cfg.passed_non_greedy && accepted.contains(cfg.root) {
      continue
    }
    let key = cfg.key()
    if seen.contains(key) {
      continue
    }
    seen[key] = true
    if state.kind == 7 {
      if cfg.returns.is_empty() {
        observed.push(cfg)
        accepted[cfg.root] = true
        match best {
          None => best = Some(cfg)
          Some(old) =>
            if cfg.pos > old.pos || (cfg.pos == old.pos && cfg.root < old.root) {
              best = Some(cfg)
            }
        }
      } else {
        let returns = cfg.returns.copy()
        let target = returns.pop().unwrap()
        work.push({ ..cfg, state: target, returns, })
      }
      continue
    }
    if state.edges.any(edge => {
        edge.kind == 2 ||
        edge.kind == 5 ||
        edge.kind == 7 ||
        edge.kind == 8 ||
        edge.kind == 9
      }) {
      observed.push(cfg)
    }
    for i = state.edges.length() - 1; i >= 0; i = i - 1 {
      let edge = state.edges[i]
      match edge.kind {
        4 => {
          semantic = true
          if (if context_predicate is Some(check) {
              let mut token_line = 1
              let mut token_column = 0
              for i in 0..<token_start {
                if chars[i] == '\n' {
                  token_line += 1
                  token_column = 0
                } else {
                  token_column += 1
                }
              }
              let mut line = token_line
              let mut column = token_column
              for i in token_start..<cfg.pos {
                if chars[i] == '\n' {
                  line += 1
                  column = 0
                } else {
                  column += 1
                }
              }
              check({
                rule: edge.a,
                predicate: edge.b,
                offset: cfg.pos,
                token_start,
                token_line,
                token_column,
                line,
                column,
                text: String::from_array(chars[token_start:cfg.pos]),
                source,
              })
            } else {
              predicate is Some(check) && check(edge.a, edge.b, cfg.pos, source)
            }) {
            work.push({ ..cfg, state: edge.target, })
          }
        }
        1 => work.push({ ..cfg, state: edge.target, })
        3 => {
          let returns = cfg.returns.copy()
          returns.push(edge.target)
          work.push({ ..cfg, state: edge.a, returns, })
        }
        6 => {
          let actions = cfg.actions.copy()
          if cfg.returns.is_empty() {
            actions.push(
              (edge.b, if atn.actions[edge.b].0 == 1 { cfg.pos } else { -1 }),
            )
          }
          work.push({ ..cfg, state: edge.target, actions, })
        }
        2 | 5 | 7 | 8 | 9 => {
          let symbol = if cfg.pos < chars.length() {
            chars[cfg.pos].to_int()
          } else {
            -1
          }
          if atn.matches(edge, symbol) {
            if symbol == -1 {
              work.push({ ..cfg, state: edge.target, matched_eof: true, })
            } else {
              next.push({ ..cfg, state: edge.target, pos: cfg.pos + 1, })
            }
          }
        }
        _ => raise Unsupported("unsupported lexer transition")
      }
    }
  }
  if trace is Some(trace) {
    ignore(
      trace.record(observed, atn, start, position, previous, semantic, chars),
    )
  }
  (best, farthest)
}

///|
/// Tokenize using the generated lexer ATN. Hidden channels are retained.
pub fn Atn::tokenize(
  self : Atn,
  source : String,
  work_limit~ : Int32 = 1_000_000,
  lexer_predicate? : LexerPredicate,
  lexer_context_predicate? : LexerContextPredicate,
  lexer_action? : LexerAction,
) -> Array[Token] raise RuntimeError {
  self.lex(
    source, work_limit, lexer_predicate, lexer_context_predicate, lexer_action, false,
  ).tokens
}

///|
/// Recover from an unmatched input segment and continue in the current mode.
pub fn Atn::tokenize_recovering(
  self : Atn,
  source : String,
  work_limit~ : Int32 = 1_000_000,
  lexer_predicate? : LexerPredicate,
  lexer_context_predicate? : LexerContextPredicate,
  lexer_action? : LexerAction,
) -> LexResult raise RuntimeError {
  self.lex(
    source, work_limit, lexer_predicate, lexer_context_predicate, lexer_action, true,
  )
}

///|
/// A demand-driven Lexer. Actions and diagnostics occur only when requested.
pub struct LexerCursor {
  mut dfa_trace : Map[Int32, LexerDfa]?
  atn : Atn
  source : String
  chars : Array[Char]
  budget : Budget
  lexer_predicate : LexerPredicate?
  lexer_context_predicate : LexerContextPredicate?
  lexer_action : LexerAction?
  recover : Bool
  errors : Array[RuntimeError]
  modes : Array[Int32]
  mut mode : Int32
  mut pos : Int32
  mut line : Int32
  mut column : Int32
  mut token_start : Int32
  mut token_line : Int32
  mut token_column : Int32
  mut continuing : Bool
  mut channel : Int32
  mut text : String?
  mut first : Bool
  mut done : Bool
  mut eof : Token?
}

///|
pub fn Atn::lexer_cursor(
  self : Atn,
  source : String,
  work_limit~ : Int32 = 1_000_000,
  lexer_predicate? : LexerPredicate,
  lexer_context_predicate? : LexerContextPredicate,
  lexer_action? : LexerAction,
  recover~ : Bool = false,
) -> LexerCursor raise RuntimeError {
  if self.kind != 0 {
    raise InvalidAtn("lexer ATN expected")
  }
  self.validate_supported(
    predicates=lexer_predicate is Some(_) || lexer_context_predicate is Some(_),
    custom_lexer_actions=lexer_action is Some(_),
  )
  {
    atn: self,
    dfa_trace: None,
    source,
    chars: source.to_array(),
    budget: { remaining: work_limit, },
    lexer_predicate,
    lexer_context_predicate,
    lexer_action,
    recover,
    errors: [],
    modes: [],
    mode: 0,
    pos: 0,
    line: 1,
    column: 0,
    token_start: 0,
    token_line: 1,
    token_column: 0,
    continuing: false,
    channel: 0,
    text: None,
    first: true,
    done: false,
    eof: None,
  }
}

///|
pub fn Grammar::lexer_cursor(
  self : Grammar,
  source : String,
  work_limit~ : Int32 = 1_000_000,
  lexer_predicate? : LexerPredicate,
  lexer_context_predicate? : LexerContextPredicate,
  lexer_action? : LexerAction,
  recover~ : Bool = false,
) -> LexerCursor raise RuntimeError {
  self.lexer.lexer_cursor(
    source,
    work_limit~,
    lexer_predicate?,
    lexer_context_predicate?,
    lexer_action?,
    recover~,
  )
}

///|
/// Diagnostics accumulated by tokens requested so far.
pub fn LexerCursor::diagnostics(self : LexerCursor) -> Array[RuntimeError] {
  self.errors.copy()
}

///|
/// Repeated EOF requests return the same Token without executing actions again.
pub fn LexerCursor::next_token(self : LexerCursor) -> Token raise RuntimeError {
  if self.eof is Some(token) {
    return token
  }
  let token = self.advance()
  if self.done {
    self.eof = Some(token)
  }
  token
}

///|
/// Reset the input for host accept-position adapters. Modes and the work
/// budget are preserved; source coordinates are recomputed.
pub fn LexerCursor::seek(
  self : LexerCursor,
  offset : Int32,
) -> Unit raise RuntimeError {
  if offset < 0 || offset > self.chars.length() {
    raise InvalidArgument("lexer position out of range")
  }
  self.pos = offset
  self.line = 1
  self.column = 0
  for i in 0..<offset {
    if self.chars[i] == '\n' {
      self.line += 1
      self.column = 0
    } else {
      self.column += 1
    }
  }
  self.continuing = false
  self.first = true
  self.done = false
  self.eof = None
}

///|
fn LexerCursor::advance(self : LexerCursor) -> Token raise RuntimeError {
  while self.first || self.pos < self.chars.length() || self.continuing {
    self.first = false
    if !self.continuing {
      self.token_start = self.pos
      self.token_line = self.line
      self.token_column = self.column
      self.channel = 0
      self.text = None
    }
    let (candidate, farthest) = lex_match(
      self.atn,
      self.chars,
      self.pos,
      self.mode,
      self.budget,
      self.source,
      self.lexer_predicate,
      self.lexer_context_predicate,
      self.token_start,
      self.dfa_trace.map(trace => {
        trace.get_or_init(self.mode, () => {
          states: [],
          interned: Map([]),
          start: None,
        })
      }),
    )
    let accepted = match candidate {
      Some(cfg) => cfg
      None => {
        if self.pos == self.chars.length() {
          break
        }
        if !self.recover {
          raise LexicalError(
            self.line,
            self.column,
            "no lexer rule matches input",
          )
        }
        self.errors.push(
          LexicalError(
            self.token_line,
            self.token_column,
            "no lexer rule matches input",
          ),
        )
        // ANTLR reports the start of the token attempt and discards the
        // partial match together with the offending scalar, unless at EOF.
        let end = (farthest + 1).min(self.chars.length())
        for i in self.pos..<end {
          if self.chars[i] == '\n' {
            self.line += 1
            self.column = 0
          } else {
            self.column += 1
          }
        }
        self.pos = end
        self.continuing = false
        continue
      }
    }
    let mut emission = Emit(self.atn.token_types[accepted.root])
    for (index, offset) in accepted.actions {
      let (action, argument, action_index) = self.atn.actions[index]
      match action {
        0 => self.channel = argument
        1 =>
          if self.lexer_action is Some(execute) {
            let event : LexerActionEvent = {
              rule: argument,
              action: action_index,
              token_start: self.token_start,
              offset,
              token_end: accepted.pos,
              emission,
              channel: self.channel,
              text: self.text,
              mode: self.mode,
              mode_stack: self.modes.copy(),
            }
            execute(event, self.source)
            emission = event.emission
            self.channel = event.channel
            self.text = event.text
            if event.mode < 0 ||
              event.mode >= self.atn.modes.length() ||
              event.mode_stack.any(value => {
                value < 0 || value >= self.atn.modes.length()
              }) {
              raise InvalidArgument("custom lexer action selected unknown mode")
            }
            self.mode = event.mode
            self.modes.clear()
            for value in event.mode_stack {
              self.modes.push(value)
            }
          }
        2 => self.mode = argument
        3 => emission = More
        4 =>
          self.mode = match self.modes.pop() {
            Some(previous) => previous
            None =>
              raise LexicalError(
                self.token_line,
                self.token_column,
                "lexer mode stack underflow",
              )
          }
        5 => {
          self.modes.push(self.mode)
          self.mode = argument
        }
        6 => emission = Skip
        7 => emission = Emit(argument)
        _ => raise Unsupported("custom lexer action")
      }
    }
    for i in self.pos..<accepted.pos {
      if self.chars[i] == '\n' {
        self.line += 1
        self.column = 0
      } else {
        self.column += 1
      }
    }
    self.pos = accepted.pos
    if self.mode < 0 || self.mode >= self.atn.modes.length() {
      raise InvalidAtn("lexer action selected unknown mode")
    }
    self.continuing = emission is More
    if emission is Emit(kind) {
      if (kind <= 0 && kind != -1) || self.channel < 0 {
        raise InvalidAtn("invalid emitted token type or channel")
      }
      let token : Token = {
        kind,
        text: match self.text {
          Some(replacement) => replacement
          None =>
            if self.token_start == self.chars.length() {
              "<EOF>"
            } else {
              String::from_array(self.chars[self.token_start:self.pos])
            }
        },
        start: self.token_start,
        end: self.pos,
        line: self.token_line,
        column: self.token_column,
        channel: self.channel,
      }
      if kind == -1 {
        self.done = true
      }
      return token
    }
  }
  let token : Token = {
    kind: -1,
    text: if self.continuing {
      match self.text {
        Some(replacement) => replacement
        None => String::from_array(self.chars[self.token_start:self.pos])
      }
    } else {
      "<EOF>"
    },
    start: if self.continuing {
      self.token_start
    } else {
      self.pos
    },
    end: self.pos,
    line: if self.continuing {
      self.token_line
    } else {
      self.line
    },
    column: if self.continuing {
      self.token_column
    } else {
      self.column
    },
    channel: if self.continuing {
      self.channel
    } else {
      0
    },
  }
  self.done = true
  token
}

///|
fn Atn::lex(
  self : Atn,
  source : String,
  work_limit : Int32,
  lexer_predicate : LexerPredicate?,
  lexer_context_predicate : LexerContextPredicate?,
  lexer_action : LexerAction?,
  recover : Bool,
) -> LexResult raise RuntimeError {
  let cursor = self.lexer_cursor(
    source,
    work_limit~,
    lexer_predicate?,
    lexer_context_predicate?,
    lexer_action?,
    recover~,
  )
  let tokens : Array[Token] = []
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
/// Tokenize a source with this grammar's lexer.
pub fn Grammar::tokenize(
  self : Grammar,
  source : String,
  work_limit~ : Int32 = 1_000_000,
  lexer_predicate? : LexerPredicate,
  lexer_context_predicate? : LexerContextPredicate,
  lexer_action? : LexerAction,
) -> Array[Token] raise RuntimeError {
  self.lexer.tokenize(
    source,
    work_limit~,
    lexer_predicate?,
    lexer_context_predicate?,
    lexer_action?,
  )
}

///|
/// Tokenize with ANTLR-style recovery and return lexical diagnostics.
pub fn Grammar::tokenize_recovering(
  self : Grammar,
  source : String,
  work_limit~ : Int32 = 1_000_000,
  lexer_predicate? : LexerPredicate,
  lexer_context_predicate? : LexerContextPredicate,
  lexer_action? : LexerAction,
) -> LexResult raise RuntimeError {
  self.lexer.tokenize_recovering(
    source,
    work_limit~,
    lexer_predicate?,
    lexer_context_predicate?,
    lexer_action?,
  )
}
