///|
/// A concrete rule invocation. Source states preserve element-label identity
/// through optional branches, repetitions, and left-recursive rewrites.
pub(all) struct RuleContext {
  name : String
  children : Array[ContextChild]
  sources : Array[Int32]
  path : Array[Int32]
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
  let children = self.children.copy()
  let sources = self.sources.copy()
  children.push(child)
  sources.push(state)
  { ..self, children, sources, }
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
/// Tokens captured by a labelled grammar element, including token sets.
pub fn RuleContext::select_tokens(
  self : RuleContext,
  states : Array[Int32],
) -> Array[Token] {
  let found : Array[Token] = []
  for i, child in self.children {
    if states.contains(self.sources[i]) {
      match child {
        TokenChild(token) => found.push(token)
        _ => ()
      }
    }
  }
  found
}

///|
/// Half-open Unicode scalar source range. Empty rules have no token range.
pub fn RuleContext::span(self : RuleContext) -> (Int32, Int32)? {
  let mut first : Int32? = None
  let mut last = 0
  for child in self.children {
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
      if first is None {
        first = Some(start)
      }
      last = end
    }
  }
  first.map(start => (start, last))
}
