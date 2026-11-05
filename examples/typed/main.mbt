///|
fn main {
  let document = @grammar.TypedParser::new().parse_document("result=(1+2)*3;") catch {
    _ => abort("example input failed to parse")
  }
  let entry = document.label_entries()[0]
  let base : @grammar.TypedVisitor[Int32] = @grammar.TypedVisitor::new(
    terminal=_ => 0,
    rule=(_, values) => values.fold(init=0, (a, b) => a + b),
  )
  let visitor = {
    ..base,
    visit_alt_Number: Some((context, _) => {
      context.as_rule().label_number()[0].text
      .to_array()
      .fold(init=0, (n, c) => n * 10 + c.to_int() - 48)
    }),
    visit_alt_Group: Some((_, values) => values[1]),
    visit_alt_Sum: Some((_, values) => values[0] + values[2]),
    visit_alt_Product: Some((_, values) => values[0] * values[2]),
  }
  println(
    entry.label_key()[0].text +
    " = " +
    visitor.visit(entry.label_value()[0].raw()).to_string(),
  )
  let numbers : Array[String] = []
  let listener = {
    ..@grammar.TypedListener::new(),
    enter_alt_Number: context => numbers.push(context.raw().text()),
  }
  listener.walk(document.raw())
  println("numbers: " + numbers.join(", "))
}
