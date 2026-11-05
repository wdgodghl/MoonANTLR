///|
fn main {
  try {
    let json = @json.grammar()
    let input = "{\"project\":\"MoonANTLR\",\"ready\":true,\"values\":[1,2,3]}"
    println("MoonANTLR / ANTLR 4.13.2 ATN interpreter")
    println(json.parse(input).to_sexpr())
    let arithmetic = @arithmetic.grammar()
    println(arithmetic.parse("1 + 2 * (3 - 4)").to_sexpr())
  } catch {
    error => {
      println("Runtime failure: " + error.to_repr().to_string())
      panic()
    }
  }
}
