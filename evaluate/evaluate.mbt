///|
pub(all) suberror EvaluationError {
  DivisionByZero
  InvalidTree(String)
} derive(Debug)

///|
pub extend EvaluationError with @debug.Debug::{to_repr}

///|
priv enum Value {
  Number(Double)
  Symbol(String)
  End
}

///|
fn number(value : Value) -> Double raise EvaluationError {
  match value {
    Number(n) => n
    _ => raise InvalidTree("number expected")
  }
}

///|
/// Evaluate the generated arithmetic grammar's tree, preserving its precedence.
pub fn evaluate(source : String) -> Double raise {
  let tree = @grammar.grammar().parse(source)
  let value = tree.fold(
    token => {
      if token.kind == -1 {
        End
      } else if token.text.iter().all(c => c >= '0' && c <= '9') {
        let n = @string.parse_double(token.text) catch {
          _ => raise InvalidTree("invalid number")
        }
        Number(n)
      } else {
        Symbol(token.text)
      }
    },
    (name, values) => {
      if name == "document" {
        return values[0]
      }
      if name == "factor" {
        return if values.length() == 1 { values[0] } else { values[1] }
      }
      if name != "expression" && name != "term" {
        raise InvalidTree("unknown arithmetic rule")
      }
      let mut result = number(values[0])
      let mut i = 1
      while i < values.length() {
        let right = number(values[i + 1])
        match values[i] {
          Symbol("+") => result += right
          Symbol("-") => result -= right
          Symbol("*") => result *= right
          Symbol("/") => {
            if right == 0.0 {
              raise DivisionByZero
            }
            result /= right
          }
          _ => raise InvalidTree("operator expected")
        }
        i += 2
      }
      Number(result)
    },
  )
  number(value)
}
