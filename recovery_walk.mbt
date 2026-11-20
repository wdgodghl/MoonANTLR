///|
/// Callbacks follow ParseTreeWalker order; error Tokens have their own callback.
pub(all) struct RecoveryListener {
  enter_rule : (String) -> Unit
  exit_rule : (String) -> Unit
  terminal : (Token) -> Unit
  error : (Token) -> Unit
}

///|
pub fn RecoveryListener::new() -> RecoveryListener {
  {
    enter_rule: _ => (),
    exit_rule: _ => (),
    terminal: _ => (),
    error: _ => (),
  }
}

///|
pub fn RecoveryListener::walk(
  self : RecoveryListener,
  tree : RecoveryTree,
) -> Unit {
  match tree {
    RuleNode(name, children) => {
      (self.enter_rule)(name)
      for child in children {
        self.walk(child)
      }
      (self.exit_rule)(name)
    }
    TokenNode(token) => (self.terminal)(token)
    ErrorNode(token, _) => (self.error)(token)
  }
}

///|
pub(all) struct RecoveryVisitor[T] {
  rule : (String, Array[T]) -> T
  terminal : (Token) -> T
  error : (Token) -> T
}

///|
pub fn[T] RecoveryVisitor::visit(
  self : RecoveryVisitor[T],
  tree : RecoveryTree,
) -> T {
  match tree {
    RuleNode(name, children) =>
      (self.rule)(name, children.map(child => self.visit(child)))
    TokenNode(token) => (self.terminal)(token)
    ErrorNode(token, _) => (self.error)(token)
  }
}
