///|
/// A concrete rule invocation. Source states preserve element-label identity
/// through optional branches, repetitions, and left-recursive rewrites.
pub(all) struct RuleContext {
  name : String
  children : Array[ContextChild]
  /// Child indices containing ANTLR error nodes rather than ordinary terminals.
  error_children : Array[Int32]
  sources : Array[Int32]
  path : Array[Int32]
  build_tree : Bool
  /// Java-compatible invocation boundaries, including the previous token for
  /// empty rules. A failed invocation leaves stop_token unset.
  start_token : Token?
  stop_token : Token?
  /// Element captures remain available to labelled accessors without a tree.
  labels : Array[(Int32, ContextChild)]
  /// Label captures returned by inline recovery need not occur in the tree.
  recovered_captures : Map[Int32, Array[(Int32, Token)]]
}

///|
pub(all) enum ContextChild {
  TokenChild(Token)
  RuleChild(RuleContext)
}

///|
fn RuleContext::append(
  self : RuleContext,
  child : ContextChild,
  state : Int32,
) -> RuleContext {
  let labels = self.labels.copy()
  labels.push((state, child))
  if !self.build_tree {
    return { ..self, labels, }
  }
  let children = self.children.copy()
  let sources = self.sources.copy()
  children.push(child)
  sources.push(state)
  { ..self, children, sources, labels, }
}

///|
fn RuleContext::enter(self : RuleContext, state : Int32) -> RuleContext {
  let path = self.path.copy()
  path.push(state)
  { ..self, path, }
}

///|
pub fn RuleContext::to_tree(self : RuleContext) -> ParseTree {
  Rule(
    self.name,
    self.children.map(child => {
      match child {
        TokenChild(token) => Terminal(token)
        RuleChild(context) => context.to_tree()
      }
    }),
  )
}

///|
/// Direct rule children, optionally restricted to grammar element states.
pub fn RuleContext::rules(
  self : RuleContext,
  name : String,
  states~ : Array[Int32] = [],
) -> Array[RuleContext] {
  let found : Array[RuleContext] = []
  if !states.is_empty() {
    for (state, child) in self.labels {
      if states.contains(state) &&
        child is RuleChild(context) &&
        context.name == name {
        found.push(context)
      }
    }
    return found
  }
  for i, child in self.children {
    if states.is_empty() || states.contains(self.sources[i]) {
      match child {
        RuleChild(context) => if context.name == name { found.push(context) }
        _ => ()
      }
    }
  }
  found
}

///|
/// Direct token children; includes EOF when kind is -1.
pub fn RuleContext::tokens(
  self : RuleContext,
  kind : Int32,
  states~ : Array[Int32] = [],
) -> Array[Token] {
  let found : Array[Token] = []
  if !states.is_empty() {
    for (state, child) in self.labels {
      if states.contains(state) &&
        child is TokenChild(token) &&
        token.kind == kind {
        found.push(token)
      }
    }
    return found
  }
  for i, child in self.children {
    if states.is_empty() || states.contains(self.sources[i]) {
      match child {
        TokenChild(token) => if token.kind == kind { found.push(token) }
        _ => ()
      }
    }
  }
  found
}

///|
/// Text of the matched subtree, excluding EOF and hidden channels.
pub fn RuleContext::text(self : RuleContext) -> String {
  let out = StringBuilder()
  for child in self.children {
    match child {
      TokenChild(token) => if token.kind != -1 { out.write_string(token.text) }
      RuleChild(context) => out.write_string(context.text())
    }
  }
  out.to_string()
}

///|
/// ANTLR ParseTree.getText semantics: concatenate visible tree children,
/// including synthetic error-node text and the literal EOF node text.
pub fn RuleContext::get_text(self : RuleContext) -> String {
  let out = StringBuilder()
  for child in self.children {
    match child {
      TokenChild(token) => out.write_string(token.text)
      RuleChild(context) => out.write_string(context.get_text())
    }
  }
  out.to_string()
}

///|
/// Tokens captured by a labelled grammar element, including token sets.
pub fn RuleContext::select_tokens(
  self : RuleContext,
  states : Array[Int32],
) -> Array[Token] {
  let found : Array[(Int32, Token)] = []
  for i, (state, child) in self.labels {
    if states.contains(state) && child is TokenChild(token) {
      found.push((i * 2 + 1, token))
    }
  }
  for state in states {
    if self.recovered_captures.get(state) is Some(tokens) {
      for (position, token) in tokens {
        found.push((position * 2, token))
      }
    }
  }
  found.mut_view().stable_sort_by((a, b) => a.0.compare(b.0))
  found.map(pair => pair.1)
}

///|
/// Half-open Unicode scalar source range. Empty rules have no token range.
pub fn RuleContext::span(self : RuleContext) -> (Int32, Int32)? {
  let mut first : Int32? = None
  let mut last = 0
  let captured = self.children + self.labels.map(pair => pair.1)
  let seen : Map[String, Bool] = Map([])
  for child in captured {
    // A built child also occurs in the detached capture log. Visit it once;
    // recursively visiting both copies would double work at every depth.
    let key = match child {
      TokenChild(token) => "t:\{token.kind}:\{token.start}:\{token.end}"
      RuleChild(context) =>
        "r:" +
        context.name +
        ":" +
        context.start_token.map(token => token.start).unwrap_or(-1).to_string() +
        ":" +
        context.stop_token.map(token => token.start).unwrap_or(-1).to_string() +
        ":" +
        context.path.map(state => state.to_string()).join(",")
    }
    if seen.contains(key) {
      continue
    }
    seen[key] = true
    let span = match child {
      TokenChild(token) =>
        if token.kind == -1 {
          None
        } else {
          Some((token.start, token.end))
        }
      RuleChild(context) => context.span()
    }
    if span is Some((start, end)) {
      first = Some(first.map(previous => previous.min(start)).unwrap_or(start))
      last = last.max(end)
    }
  }
  first.map(start => (start, last))
}
