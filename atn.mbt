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
fn is_decision(kind : Int32) -> Bool {
  kind == 3 || kind == 4 || kind == 5 || kind == 6 || kind == 10 || kind == 11
}

///|
/// ANTLR marks only the outer rewritten loop as a precedence decision.
/// An EBNF star nested in the same rule must not create recursive contexts.
fn Atn::is_precedence_decision(self : Atn, index : Int32) -> Bool {
  let state = self.states[index]
  if state.kind != 10 || !self.states[self.starts[state.rule]].precedence {
    return false
  }
  if state.edges.last() is Some(edge) {
    let end = self.states[edge.target]
    if end.kind == 12 && end.edges.length() == 1 {
      let exit = end.edges[0]
      return exit.kind == 1 && self.states[exit.target].kind == 7
    }
  }
  false
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
  let links : Array[(Int32, Int32)] = []
  let nstates = rd.count()
  for _ in 0..<nstates {
    let state_kind = rd.read()
    if state_kind < 0 || state_kind > 12 {
      raise InvalidAtn("unknown state type")
    }
    let rule = if state_kind == 0 { -1 } else { rd.read() }
    if state_kind == 12 || state_kind == 3 || state_kind == 4 || state_kind == 5 {
      links.push((state_kind, rd.read()))
    }
    states.push({
      kind: state_kind,
      rule,
      non_greedy: false,
      precedence: false,
      edges: [],
    })
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
  for (source_kind, target) in links {
    atn.check_state(target)
    let target_kind = atn.states[target].kind
    if source_kind == 12 {
      if target_kind != 9 && target_kind != 11 {
        raise InvalidAtn("loopback state expected")
      }
    } else if target_kind != 8 {
      raise InvalidAtn("block end state expected")
    }
  }
  for _ in 0..<nnon_greedy {
    let state = rd.read()
    atn.check_state(state)
    if !is_decision(atn.states[state].kind) {
      raise InvalidAtn("non-greedy flag requires a decision state")
    }
    atn.states[state].non_greedy = true
  }
  let nprecedence = rd.count()
  for _ in 0..<nprecedence {
    let state = rd.read()
    atn.check_state(state)
    if atn.states[state].kind != 2 {
      raise InvalidAtn("precedence flag requires a rule start")
    }
    atn.states[state].precedence = true
  }
  let nrules = rd.count()
  if nrules == 0 {
    raise InvalidAtn("ATN must contain a rule")
  }
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
  if (kind == 1 && nmodes != 0) || (kind == 0 && nmodes == 0) {
    raise InvalidAtn("grammar/mode table mismatch")
  }
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
      let minimum = if kind == 0 { 0 } else { 1 }
      let maximum = if kind == 0 { 0x10FFFF } else { max_token }
      if lo < minimum || hi < lo || hi > maximum {
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
    if edge_kind == 2 || edge_kind == 5 {
      let maximum = if kind == 0 { 0x10FFFF } else { max_token }
      if c != 0 && c != 1 {
        raise InvalidAtn("invalid EOF transition flag")
      }
      if c == 0 && (a < (if kind == 0 { 0 } else { 1 }) || a > maximum) {
        raise InvalidAtn("transition symbol out of bounds")
      }
      if edge_kind == 2 && (b < a || b > maximum) {
        raise InvalidAtn("transition range out of bounds")
      }
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
    let state = rd.read()
    atn.check_state(state)
    if !is_decision(atn.states[state].kind) {
      raise InvalidAtn("decision table references a non-decision state")
    }
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
      if (action == 2 || action == 5) && (a < 0 || a >= nmodes) {
        raise InvalidAtn("lexer action mode out of bounds")
      }
      if action == 0 && a < 0 {
        raise InvalidAtn("negative lexer channel")
      }
      if action == 7 && a != -1 && (a < 1 || a > max_token) {
        raise InvalidAtn("lexer action token type out of bounds")
      }
      atn.actions.push((action, a, b))
    }
  }
  if rd.offset != data.length() {
    raise InvalidAtn("trailing serialized ATN data")
  }
  let stops : Array[Int32] = Array::make(nrules, 0)
  for state in atn.states {
    if state.kind != 0 &&
      state.kind != 6 &&
      (state.rule < 0 || state.rule >= nrules) {
      raise InvalidAtn("invalid state rule index")
    }
    if state.kind == 6 && state.rule != -1 {
      raise InvalidAtn("mode state must not belong to a rule")
    }
    if state.kind == 7 {
      stops[state.rule] += 1
    }
    for edge in state.edges {
      if kind == 0 &&
        edge.kind == 6 &&
        (edge.b < 0 || edge.b >= atn.actions.length()) {
        raise InvalidAtn("invalid lexer action reference")
      }
    }
  }
  if stops.any(count => count != 1) {
    raise InvalidAtn("each rule must have one stop state")
  }
  if atn.token_types.any(token => token < 0 || token > max_token) {
    raise InvalidAtn("rule token type out of bounds")
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
    if state.non_greedy {
      raise Unsupported("non-greedy lexer decisions")
    }
    for edge in state.edges {
      if edge.kind == 4 {
        raise Unsupported("semantic predicates")
      }
      if self.kind == 1 &&
        edge.kind == 6 &&
        !(edge.b == -1 && self.states[self.starts[state.rule]].precedence) {
        raise Unsupported("embedded parser actions")
      }
    }
  }
  for action in self.actions {
    if action.0 == 7 && action.1 == -1 {
      raise Unsupported("lexer EOF remapping")
    }
    if action.0 == 1 {
      raise Unsupported("custom lexer actions")
    }
  }
}
