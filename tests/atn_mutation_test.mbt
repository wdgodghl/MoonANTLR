///|
test "every truncated lexer artifact returns a typed decoder failure" {
  let data = @json.lexer_data()
  for end in 0..<data.length() {
    let rejected = try {
      let _ = @runtime.deserialize(data[:end].to_owned())
      false
    } catch {
      @runtime.InvalidAtn(_) => true
      _ => false
    }
    assert_true(rejected)
  }
}

///|
test "field mutations cannot escape ATN bounds checks" {
  for original in [@json.lexer_data(), @json.parser_data(), @modes.lexer_data()] {
    let mut rejected = 0
    for index in 0..<original.length() {
      for sentinel in [-1, 2147483647] {
        let data = original.copy()
        data[index] = sentinel
        try {
          let _ = @runtime.deserialize(data)
        } catch {
          @runtime.InvalidAtn(_) => rejected += 1
          error =>
            fail("unexpected decoder failure: " + error.to_repr().to_string())
        }
      }
    }
    assert_true(rejected > original.length())
  }
}
