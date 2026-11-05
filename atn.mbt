// ANTLR serialized ATN version 4 layout follows the ANTLR 4.13.2 reference
// runtime. Upstream copyright and BSD terms: licenses/ANTLR-LICENSE.txt.

///|
priv struct Reader {
  data : Array[Int32]
  mut offset : Int32
}

///|
fn Reader::read(self : Reader) -> Int32 raise RuntimeError {
  if self.offset >= self.data.length() {
    raise InvalidAtn("truncated serialized ATN")
  }
  let value = self.data[self.offset]
  self.offset += 1
  value
}

///|
fn Reader::count(self : Reader) -> Int32 raise RuntimeError {
  let n = self.read()
  if n < 0 || n > self.data.length() {
    raise InvalidAtn("invalid section length")
  }
  n
}

///|
fn Atn::check_state(self : Atn, index : Int32) -> Unit raise RuntimeError {
  if index < 0 || index >= self.states.length() || self.states[index].kind == 0 {
    raise InvalidAtn("invalid state reference: " + index.to_string())
  }
}

///|
/// Decode the integer form emitted by ANTLR 4.13.2's .interp artifacts.
pub fn deserialize(data : Array[Int32]) -> Atn raise RuntimeError {
  let rd = Reader::{ data, offset: 0, }
  if rd.read() != 4 {
    raise InvalidAtn("expected serialized ATN version 4")
  }
  let kind = rd.read()
  if kind != 0 && kind != 1 {
    raise InvalidAtn("unknown grammar type")
  }
  let max_token = rd.read()
  if max_token < 0 || max_token > 65535 {
    raise InvalidAtn("maximum token type outside supported bounds")
  }
  let states : Array[State] = []
  let nstates = rd.count()
  for _ in 0..<nstates {
    let state_kind = rd.read()
    if state_kind < 0 || state_kind > 12 {
      raise InvalidAtn("unknown state type")
    }
    let rule = if state_kind == 0 { -1 } else { rd.read() }
    if state_kind == 12 || state_kind == 3 || state_kind == 4 || state_kind == 5 {
      let _ = rd.read()
    }
    states.push({ kind: state_kind, rule, non_greedy: false, edges: [], })
  }
  let atn : Atn = {
    kind,
    max_token,
    states,
    starts: [],
    token_types: [],
    modes: [],
    sets: [],
    actions: [],
  }
  let nnon_greedy = rd.count()
  for _ in 0..<nnon_greedy {
    let state = rd.read()
    atn.check_state(state)
    atn.states[state].non_greedy = true
  }
  let nprecedence = rd.count()
  for _ in 0..<nprecedence {
    atn.check_state(rd.read())
  }
  let nrules = rd.count()
  for index in 0..<nrules {
    let state = rd.read()
    atn.check_state(state)
    if atn.states[state].kind != 2 {
      raise InvalidAtn("rule start state expected")
    }
    if atn.states[state].rule != index {
      raise InvalidAtn("rule start index mismatch")
    }
    atn.starts.push(state)
    if kind == 0 {
      atn.token_types.push(rd.read())
    }
  }
  let nmodes = rd.count()
  for _ in 0..<nmodes {
    let state = rd.read()
    atn.check_state(state)
    if atn.states[state].kind != 6 {
      raise InvalidAtn("lexer mode start state expected")
    }
    atn.modes.push(state)
  }
  let nsets = rd.count()
  for _ in 0..<nsets {
    let nintervals = rd.count()
    let eof = rd.read()
    if eof != 0 && eof != 1 {
      raise InvalidAtn("invalid EOF set flag")
    }
    let intervals : Array[(Int32, Int32)] = []
    if eof == 1 {
      intervals.push((-1, -1))
    }
    for _ in 0..<nintervals {
      let lo = rd.read()
      let hi = rd.read()
      if lo < 0 || hi < lo {
        raise InvalidAtn("invalid interval")
      }
      intervals.push((lo, hi))
    }
    atn.sets.push(intervals)
  }
  let nedges = rd.count()
  for _ in 0..<nedges {
    let src = rd.read()
    let target = rd.read()
    let edge_kind = rd.read()
    let a = rd.read()
    let b = rd.read()
    let c = rd.read()
    atn.check_state(src)
    atn.check_state(target)
    if edge_kind < 1 || edge_kind > 10 {
      raise InvalidAtn("unknown transition type")
    }
    if edge_kind == 3 {
      atn.check_state(a)
      if b < 0 || b >= atn.starts.length() {
        raise InvalidAtn("invalid rule index")
      }
      if atn.states[a].kind != 2 || atn.states[a].rule != b {
        raise InvalidAtn("rule transition target mismatch")
      }
    }
    if (edge_kind == 7 || edge_kind == 8) && (a < 0 || a >= atn.sets.length()) {
      raise InvalidAtn("invalid interval set reference")
    }
    atn.states[src].edges.push({ target, kind: edge_kind, a, b, c, })
  }
  let ndecisions = rd.count()
  for _ in 0..<ndecisions {
    atn.check_state(rd.read())
  }
  if kind == 0 {
    let nactions = rd.count()
    for _ in 0..<nactions {
      let action = rd.read()
      let a = rd.read()
      let b = rd.read()
      if action < 0 || action > 7 {
        raise InvalidAtn("unknown lexer action")
      }
      atn.actions.push((action, a, b))
    }
  }
  if rd.offset != data.length() {
    raise InvalidAtn("trailing serialized ATN data")
  }
  for state in atn.states {
    if state.kind != 0 &&
      state.kind != 6 &&
      (state.rule < 0 || state.rule >= nrules) {
      raise InvalidAtn("invalid state rule index")
    }
    for edge in state.edges {
      if kind == 0 &&
        edge.kind == 6 &&
        (edge.b < 0 || edge.b >= atn.actions.length()) {
        raise InvalidAtn("invalid lexer action reference")
      }
    }
  }
  atn
}

///|
fn Atn::matches(self : Atn, edge : Edge, symbol : Int32) -> Bool {
  match edge.kind {
    2 => (edge.c != 0 && symbol == -1) || (symbol >= edge.a && symbol <= edge.b)
    5 => symbol == (if edge.c != 0 { -1 } else { edge.a })
    7 | 8 => {
      let inside = self.sets[edge.a].any(pair => {
        symbol >= pair.0 && symbol <= pair.1
      })
      if edge.kind == 8 {
        symbol >= 0 && !inside
      } else {
        inside
      }
    }
    9 => symbol >= 0 && (self.kind == 0 || symbol <= self.max_token)
    _ => false
  }
}

///|
/// Unsupported control flow is rejected before tokenization or parsing.
fn Atn::validate_supported(self : Atn) -> Unit raise RuntimeError {
  for state in self.states {
    for edge in state.edges {
      if edge.kind == 10 {
        raise Unsupported("precedence predicates")
      }
    }
  }
  for state in self.states {
    if state.non_greedy {
      raise Unsupported("non-greedy lexer decisions")
    }
    for edge in state.edges {
      if edge.kind == 4 {
        raise Unsupported("semantic predicates")
      }
      if self.kind == 1 && edge.kind == 6 {
        raise Unsupported("embedded parser actions")
      }
    }
  }
  for action in self.actions {
    if action.0 == 1 {
      raise Unsupported("custom lexer actions")
    }
  }
}
