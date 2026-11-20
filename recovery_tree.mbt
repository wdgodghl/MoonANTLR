///|
/// Error nodes retain the original Token and the committed repair operation.
pub(all) enum RecoveryTree {
  RuleNode(String, Array[RecoveryTree])
  TokenNode(Token)
  ErrorNode(Token, String)
}

///|
fn child_span(child : ContextChild) -> (Int32, Int32)? {
  match child {
    RuleChild(context) => context.span()
    TokenChild(token) => Some((token.start, token.end))
  }
}

///|
fn recovery_tree(
  context : RuleContext,
  inserted : Array[Token],
  deleted : Array[(Token, String)],
) -> RecoveryTree {
  let children : Array[RecoveryTree] = []
  let pending = deleted.copy()
  pending.sort_by((a, b) => a.0.start.compare(b.0.start))
  for child in context.children {
    let span = child_span(child)
    let nested : Array[(Token, String)] = []
    if span is Some((start, end)) {
      while !pending.is_empty() && pending[0].0.start < start {
        let removed = pending.remove(0)
        children.push(ErrorNode(removed.0, removed.1))
      }
      if child is RuleChild(_) {
        while !pending.is_empty() && pending[0].0.end <= end {
          nested.push(pending.remove(0))
        }
      }
    }
    children.push(
      match child {
        RuleChild(rule) => recovery_tree(rule, inserted, nested)
        TokenChild(token) =>
          if inserted.contains(token) {
            ErrorNode(token, "inserted")
          } else {
            TokenNode(token)
          }
      },
    )
  }
  for (token, operation) in pending {
    children.push(ErrorNode(token, operation))
  }
  RuleNode(context.name, children)
}

///|
/// Include inserted and discarded Tokens in a separate recovery tree.
pub fn RecoveryResult::tree_with_errors(self : RecoveryResult) -> RecoveryTree? {
  let inserted : Array[Token] = []
  let removed : Array[(Token, String)] = []
  for repair in self.repairs {
    match repair {
      Inserted(token) => inserted.push(token)
      Deleted(token) => removed.push((token, "deleted"))
      Synchronized(tokens) =>
        for token in tokens {
          removed.push((token, "synchronized"))
        }
    }
  }
  self.context.map(context => recovery_tree(context, inserted, removed))
}

///|
pub fn RecoveryTree::to_json(self : RecoveryTree) -> Json {
  match self {
    RuleNode(name, children) =>
      {
        "rule": Json::string(name),
        "children": Json::array(children.map(child => child.to_json())),
      }
    TokenNode(token) => { "token": token.to_json() }
    ErrorNode(token, operation) =>
      { "token": token.to_json(), "error": Json::string(operation) }
  }
}

///|
/// Canonical tree notation that distinguishes error nodes from terminals.
pub fn RecoveryTree::to_sexpr(self : RecoveryTree) -> String {
  match self {
    RuleNode(name, children) =>
      "(" + name + children.map(child => " " + child.to_sexpr()).join("") + ")"
    TokenNode(token) =>
      if token.kind == -1 {
        "<EOF>"
      } else {
        token.text.escape()
      }
    ErrorNode(token, _) => "(error " + token.text.escape() + ")"
  }
}

///|
/// Error Tokens in Listener traversal order, including synthetic Tokens.
pub fn RecoveryTree::error_tokens(self : RecoveryTree) -> Array[Token] {
  match self {
    ErrorNode(token, _) => [token]
    TokenNode(_) => []
    RuleNode(_, children) => {
      let tokens : Array[Token] = []
      for child in children {
        for token in child.error_tokens() {
          tokens.push(token)
        }
      }
      tokens
    }
  }
}
