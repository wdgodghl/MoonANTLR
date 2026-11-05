///|
test "CSV reader handles quoted delimiters, doubled quotes and embedded newlines" {
  let rows = @csv.read(
    "name,note\r\nalpha,\"hello,world\"\r\nbeta,\"line1\nline2\"\r\n",
  )
  @debug.assert_eq(rows, [
    ["name", "note"],
    ["alpha", "hello,world"],
    ["beta", "line1\nline2"],
  ])
  @debug.assert_eq(@csv.read("\"a\"\"b\",中文😀"), [["a\"b", "中文😀"]])
}

///|
test "CSV empty sources, fields and final record separators are explicit" {
  @debug.assert_eq(@csv.read(""), [])
  @debug.assert_eq(@csv.read(",,"), [["", "", ""]])
  @debug.assert_eq(@csv.read("a,b\n"), [["a", "b"]])
  @debug.assert_eq(@csv.read("\n"), [[""]])
}

///|
test "CSV reader rejects malformed quotes and standalone carriage returns" {
  for source in ["\"unfinished", "a,\"b\"x", "a\rb"] {
    let rejected = try {
      let _ = @csv.read(source)
      false
    } catch {
      _ => true
    }
    assert_true(rejected)
  }
}
