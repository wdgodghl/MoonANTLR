///|
priv enum Value {
  Text(String)
  Row(Array[String])
  Rows(Array[Array[String]])
  Separator
}

///| Read comma-delimited records, including quoted newlines and doubled quotes.

///| Empty source has no records; blank records contain one empty field. A final

///|
/// line terminator does not create an additional record.
pub fn read(
  source : String,
) -> Array[Array[String]] raise @runtime.RuntimeError {
  let grammar = @grammar.grammar()
  let tree = grammar.parse(source)
  if source.is_empty() {
    return []
  }
  let value = tree.fold(
    token => {
      match grammar.token_name(token.kind) {
        "QUOTED" =>
          Text(
            token.text[1:token.text.length() - 1]
            .to_owned()
            .replace_all(old="\"\"", new="\""),
          )
        "TEXT" => Text(token.text)
        _ => Separator
      }
    },
    (name, children) => {
      match name {
        "field" => if children.is_empty() { Text("") } else { children[0] }
        "row" => {
          let fields : Array[String] = []
          for child in children {
            if child is Text(value) {
              fields.push(value)
            }
          }
          Row(fields)
        }
        _ => {
          let rows : Array[Array[String]] = []
          for child in children {
            if child is Row(row) {
              rows.push(row)
            }
          }
          Rows(rows)
        }
      }
    },
  )
  match value {
    Rows(rows) => {
      if source.has_suffix("\n") {
        let _ = rows.pop()
      }
      rows
    }
    _ => raise @runtime.InvalidArgument("CSV document tree expected")
  }
}
