// DFA observation follows ANTLR 4.13.2 LexerATNSimulator/DFASerializer.
// BSD-3-Clause; see licenses/ANTLR-LICENSE.txt.

///|
pub struct LexerDfaNode {
  prediction : Int32
  edges : Map[Int32, Int32]
}

///|
pub struct LexerDfa {
  states : Array[LexerDfaNode]
  interned : Map[String, Int32]
  mut start : Int32?
}

///|
fn LexerDfa::intern(
  self : LexerDfa,
  configs : Array[LexConfig],
  atn : Atn,
  start : Int32,
) -> Int32 {
  let keys = configs.map(cfg => {
    {
      ..cfg,
      pos: 0,
      actions: cfg.actions.map(action => {
        (action.0, if action.1 < 0 { -1 } else { action.1 - start })
      }),
    }.key()
  })
  keys.sort()
  let key = keys.join(";")
  if self.interned.get(key) is Some(id) {
    return id
  }
  let mut prediction = 0
  for cfg in configs {
    if atn.states[cfg.state].kind == 7 && cfg.returns.is_empty() {
      prediction = atn.token_types[cfg.root]
      break
    }
  }
  let id = self.states.length()
  self.interned[key] = id
  self.states.push({ prediction, edges: Map([]), })
  id
}

///|
fn LexerDfaNode::label(self : LexerDfaNode, id : Int32) -> String {
  (if self.prediction == 0 { "s" } else { ":s" }) +
  id.to_string() +
  (if self.prediction == 0 { "" } else { "=>" + self.prediction.to_string() })
}

///|
/// Record real closure sets. Predicate-dependent start states and edges are
/// deliberately not cached, just as in LexerATNSimulator.
fn LexerDfa::record(
  self : LexerDfa,
  configs : Array[LexConfig],
  atn : Atn,
  start : Int32,
  position : Int32,
  previous : Int32?,
  predicate : Bool,
  chars : Array[Char],
) -> Int32? {
  if configs.is_empty() {
    return None
  }
  let id = self.intern(configs, atn, start)
  if previous is Some(previous) {
    if !predicate && position > start {
      let symbol = chars[position - 1].to_int()
      if symbol <= 127 {
        self.states[previous].edges[symbol] = id
      }
    }
  } else if !predicate {
    self.start = Some(id)
  }
  Some(id)
}

///|
fn LexerDfa::dump(self : LexerDfa) -> String {
  if self.start is None {
    return ""
  }
  let output = StringBuilder()
  let mut any = false
  for id, state in self.states {
    let symbols = state.edges.keys().collect()
    symbols.sort()
    for symbol in symbols {
      let target = state.edges[symbol]
      output.write_string(
        state.label(id) +
        "-'" +
        symbol.unsafe_to_char().to_string() +
        "'->" +
        self.states[target].label(target) +
        "\n",
      )
      any = true
    }
  }
  if any {
    output.to_string()
  } else {
    "null"
  }
}

///|
/// Enable deterministic DFA observations without changing token recognition.
pub fn LexerCursor::enable_dfa_trace(self : LexerCursor) -> Unit {
  self.dfa_trace = Some(Map([]))
}

///|
/// ANTLR-compatible Lexer DFA serialization for one mode.
pub fn LexerCursor::dump_dfa(self : LexerCursor, mode~ : Int32 = 0) -> String {
  match self.dfa_trace {
    Some(trace) =>
      match trace.get(mode) {
        Some(dfa) => dfa.dump()
        None => "null"
      }
    None => "null"
  }
}
