///|
/// A pure Lexer predicate. Offsets are Unicode scalar indices in source.
pub type LexerPredicate = (Int32, Int32, Int32, String) -> Bool

///|
priv struct Budget {
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
  while !work.is_empty() || !next.is_empty() {
    if work.is_empty() {
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
    for i = state.edges.length() - 1; i >= 0; i = i - 1 {
      let edge = state.edges[i]
      match edge.kind {
        4 =>
          if predicate is Some(check) && check(edge.a, edge.b, cfg.pos, source) {
            work.push({ ..cfg, state: edge.target, })
          }
        1 => work.push({ ..cfg, state: edge.target, })
        3 => {
          if cfg.returns.length() >= 64 {
            raise LimitExceeded("lexer rule nesting exceeds 64")
          }
          let returns = cfg.returns.copy()
          returns.push(edge.target)
          work.push({ ..cfg, state: edge.a, returns, })
        }
        6 => {
          let actions = cfg.actions.copy()
          actions.push(
            (edge.b, if atn.actions[edge.b].0 == 1 { cfg.pos } else { -1 }),
          )
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
  (best, farthest)
}

///|
/// Tokenize using the generated lexer ATN. Hidden channels are retained.
pub fn Atn::tokenize(
  self : Atn,
  source : String,
  work_limit~ : Int32 = 1_000_000,
  lexer_predicate? : LexerPredicate,
  lexer_action? : LexerAction,
) -> Array[Token] raise RuntimeError {
  self.lex(source, work_limit, lexer_predicate, lexer_action, false).tokens
}

///|
/// Recover from an unmatched input segment and continue in the current mode.
pub fn Atn::tokenize_recovering(
  self : Atn,
  source : String,
  work_limit~ : Int32 = 1_000_000,
  lexer_predicate? : LexerPredicate,
  lexer_action? : LexerAction,
) -> LexResult raise RuntimeError {
  self.lex(source, work_limit, lexer_predicate, lexer_action, true)
}

///|
fn Atn::lex(
  self : Atn,
  source : String,
  work_limit : Int32,
  lexer_predicate : LexerPredicate?,
  lexer_action : LexerAction?,
  recover : Bool,
) -> LexResult raise RuntimeError {
  if self.kind != 0 {
    raise InvalidAtn("lexer ATN expected")
  }
  self.validate_supported(
    predicates=lexer_predicate is Some(_),
    custom_lexer_actions=lexer_action is Some(_),
  )
  let budget = Budget::{ remaining: work_limit, }
  let chars = source.to_array()
  let tokens : Array[Token] = []
  let errors : Array[RuntimeError] = []
  let modes : Array[Int32] = []
  let mut mode = 0
  let mut pos = 0
  let mut line = 1
  let mut column = 0
  let mut token_start = 0
  let mut token_line = 1
  let mut token_column = 0
  let mut continuing = false
  let mut channel = 0
  let mut text : String? = None
  let mut first = true
  while first || pos < chars.length() || continuing {
    first = false
    if !continuing {
      token_start = pos
      token_line = line
      token_column = column
      channel = 0
      text = None
    }
    let (candidate, farthest) = lex_match(
      self, chars, pos, mode, budget, source, lexer_predicate,
    )
    let accepted = match candidate {
      Some(cfg) => cfg
      None => {
        if pos == chars.length() {
          break
        }
        if !recover {
          raise LexicalError(line, column, "no lexer rule matches input")
        }
        errors.push(
          LexicalError(token_line, token_column, "no lexer rule matches input"),
        )
        // ANTLR reports the start of the token attempt and discards the
        // partial match together with the offending scalar, unless at EOF.
        let end = (farthest + 1).min(chars.length())
        for i in pos..<end {
          if chars[i] == '\n' {
            line += 1
            column = 0
          } else {
            column += 1
          }
        }
        pos = end
        continuing = false
        continue
      }
    }
    if accepted.pos == pos && !accepted.matched_eof {
      raise Unsupported("zero-width lexer token")
    }
    let mut emission = Emit(self.token_types[accepted.root])
    for (index, offset) in accepted.actions {
      let (action, argument, action_index) = self.actions[index]
      match action {
        0 => channel = argument
        1 =>
          if lexer_action is Some(execute) {
            let event : LexerActionEvent = {
              rule: argument,
              action: action_index,
              token_start,
              offset,
              token_end: accepted.pos,
              emission,
              channel,
              text,
              mode,
              mode_stack: modes.copy(),
            }
            execute(event, source)
            emission = event.emission
            channel = event.channel
            text = event.text
            if event.mode < 0 ||
              event.mode >= self.modes.length() ||
              event.mode_stack.any(value => {
                value < 0 || value >= self.modes.length()
              }) {
              raise InvalidArgument("custom lexer action selected unknown mode")
            }
            mode = event.mode
            modes.clear()
            for value in event.mode_stack {
              modes.push(value)
            }
          }
        2 => mode = argument
        3 => emission = More
        4 =>
          mode = match modes.pop() {
            Some(previous) => previous
            None =>
              raise LexicalError(
                token_line, token_column, "lexer mode stack underflow",
              )
          }
        5 => {
          modes.push(mode)
          mode = argument
        }
        6 => emission = Skip
        7 => emission = Emit(argument)
        _ => raise Unsupported("custom lexer action")
      }
    }
    for i in pos..<accepted.pos {
      if chars[i] == '\n' {
        line += 1
        column = 0
      } else {
        column += 1
      }
    }
    pos = accepted.pos
    if mode < 0 || mode >= self.modes.length() {
      raise InvalidAtn("lexer action selected unknown mode")
    }
    continuing = emission is More
    if emission is Emit(kind) {
      if (kind <= 0 && kind != -1) || kind > self.max_token || channel < 0 {
        raise InvalidAtn("invalid emitted token type or channel")
      }
      tokens.push({
        kind,
        text: match text {
          Some(replacement) => replacement
          None =>
            if token_start == chars.length() {
              "<EOF>"
            } else {
              String::from_array(chars[token_start:pos])
            }
        },
        start: token_start,
        end: pos,
        line: token_line,
        column: token_column,
        channel,
      })
      if kind == -1 {
        return { tokens, errors, }
      }
    }
  }
  tokens.push({
    kind: -1,
    text: if continuing {
      match text {
        Some(replacement) => replacement
        None => String::from_array(chars[token_start:pos])
      }
    } else {
      "<EOF>"
    },
    start: if continuing {
      token_start
    } else {
      pos
    },
    end: pos,
    line: if continuing {
      token_line
    } else {
      line
    },
    column: if continuing {
      token_column
    } else {
      column
    },
    channel: if continuing {
      channel
    } else {
      0
    },
  })
  { tokens, errors, }
}

///|
/// Tokenize a source with this grammar's lexer.
pub fn Grammar::tokenize(
  self : Grammar,
  source : String,
  work_limit~ : Int32 = 1_000_000,
  lexer_predicate? : LexerPredicate,
  lexer_action? : LexerAction,
) -> Array[Token] raise RuntimeError {
  self.lexer.tokenize(source, work_limit~, lexer_predicate?, lexer_action?)
}

///|
/// Tokenize with ANTLR-style recovery and return lexical diagnostics.
pub fn Grammar::tokenize_recovering(
  self : Grammar,
  source : String,
  work_limit~ : Int32 = 1_000_000,
  lexer_predicate? : LexerPredicate,
  lexer_action? : LexerAction,
) -> LexResult raise RuntimeError {
  self.lexer.tokenize_recovering(
    source,
    work_limit~,
    lexer_predicate?,
    lexer_action?,
  )
}
