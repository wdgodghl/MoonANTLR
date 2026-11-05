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
priv struct LexConfig {
  state : Int32
  pos : Int32
  root : Int32
  returns : Array[Int32]
  actions : Array[Int32]
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
  for n in self.returns {
    out.write_string("/" + n.to_string())
  }
  out.write_string(":")
  for n in self.actions {
    out.write_string("/" + n.to_string())
  }
  out.to_string()
}

///|
/// Exhaustive bounded NFA execution: longest match, then rule declaration order.
fn lex_match(
  atn : Atn,
  chars : Array[Char],
  start : Int32,
  mode : Int32,
  budget : Budget,
) -> LexConfig? raise RuntimeError {
  if mode < 0 || mode >= atn.modes.length() {
    raise InvalidAtn("unknown lexer mode")
  }
  let work : Array[LexConfig] = []
  for edge in atn.states[atn.modes[mode]].edges {
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
    })
  }
  let seen : Map[String, Bool] = Map([])
  let mut best : LexConfig? = None
  while work.length() > 0 {
    budget.tick()
    let cfg = work.pop().unwrap()
    let key = cfg.key()
    if seen.contains(key) {
      continue
    }
    seen[key] = true
    let state = atn.states[cfg.state]
    if state.kind == 7 {
      if cfg.returns.is_empty() {
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
    for edge in state.edges {
      match edge.kind {
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
          actions.push(edge.b)
          work.push({ ..cfg, state: edge.target, actions, })
        }
        2 | 5 | 7 | 8 | 9 => {
          let symbol = if cfg.pos < chars.length() {
            chars[cfg.pos].to_int()
          } else {
            -1
          }
          if atn.matches(edge, symbol) {
            work.push({
              ..cfg,
              state: edge.target,
              pos: cfg.pos + (if symbol == -1 { 0 } else { 1 }),
            })
          }
        }
        _ => raise Unsupported("unsupported lexer transition")
      }
    }
  }
  best
}

///|
/// Tokenize using the generated lexer ATN. Hidden channels are retained.
pub fn Atn::tokenize(
  self : Atn,
  source : String,
  work_limit~ : Int32 = 1_000_000,
) -> Array[Token] raise RuntimeError {
  if self.kind != 0 {
    raise InvalidAtn("lexer ATN expected")
  }
  self.validate_supported()
  let budget = Budget::{ remaining: work_limit, }
  let chars = source.to_array()
  let tokens : Array[Token] = []
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
  while pos < chars.length() {
    if !continuing {
      token_start = pos
      token_line = line
      token_column = column
      channel = 0
    }
    let accepted = match lex_match(self, chars, pos, mode, budget) {
      Some(cfg) => cfg
      None => raise LexicalError(line, column, "no lexer rule matches input")
    }
    if accepted.pos == pos {
      raise Unsupported("zero-width lexer token")
    }
    let mut kind = self.token_types[accepted.root]
    let mut skip = false
    let mut more = false
    for index in accepted.actions {
      let (action, argument, _) = self.actions[index]
      match action {
        0 => channel = argument
        2 => mode = argument
        3 => more = true
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
        6 => skip = true
        7 => kind = argument
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
    continuing = more && !skip
    if !skip && !more {
      if kind <= 0 || kind > self.max_token || channel < 0 {
        raise InvalidAtn("invalid emitted token type or channel")
      }
      tokens.push({
        kind,
        text: String::from_array(chars[token_start:pos]),
        start: token_start,
        end: pos,
        line: token_line,
        column: token_column,
        channel,
      })
    }
  }
  tokens.push({
    kind: -1,
    text: if continuing {
      String::from_array(chars[token_start:pos])
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
  tokens
}

///|
/// Tokenize a source with this grammar's lexer.
pub fn Grammar::tokenize(
  self : Grammar,
  source : String,
  work_limit~ : Int32 = 1_000_000,
) -> Array[Token] raise RuntimeError {
  self.lexer.tokenize(source, work_limit~)
}
