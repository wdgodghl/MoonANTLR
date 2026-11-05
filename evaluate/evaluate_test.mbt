///|
test "evaluation respects precedence, parentheses and left associativity" {
  assert_eq(@evaluate.evaluate("1+2*3"), 7.0)
  assert_eq(@evaluate.evaluate("(1+2)*3"), 9.0)
  assert_eq(@evaluate.evaluate("10-3-2"), 5.0)
  assert_eq(@evaluate.evaluate("8/2/2"), 2.0)
  assert_eq(@evaluate.evaluate("1+2*(3-4)"), -1.0)
}

///|
test "division by zero is an application error" {
  let rejected = try {
    let _ = @evaluate.evaluate("1/(2-2)")
    false
  } catch {
    @evaluate.DivisionByZero => true
    _ => false
  }
  assert_true(rejected)
}
