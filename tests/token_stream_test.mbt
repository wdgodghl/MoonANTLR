///|
test "lookahead and seek skip hidden tokens while preserving physical positions" {
  let tokens = @modes.grammar().tokenize("alpha //comment\nbeta")
  let stream = @runtime.TokenStream::new(tokens)
  assert_eq(stream.lookahead(1).text, "alpha")
  assert_eq(stream.lookahead(2).text, "beta")
  assert_eq(stream.lookahead(99999).kind, -1)
  stream.consume()
  assert_eq(stream.index(), 2)
  stream.seek(1)
  assert_eq(stream.lookahead(1).text, "beta")
  let hidden = @runtime.TokenStream::new(tokens, channel=1)
  assert_eq(hidden.lookahead(1).text, "//comment")
  assert_eq(hidden.lookahead(2).kind, -1)
}

///|
test "token streams own their buffers and reject invalid cursor operations" {
  let tokens = @json.grammar().tokenize("null")
  let stream = @runtime.TokenStream::new(tokens)
  tokens.clear()
  let returned = stream.all_tokens()
  returned.clear()
  assert_eq(stream.lookahead(1).text, "null")
  stream.consume()
  let rejected = try {
    stream.consume()
    false
  } catch {
    @runtime.InvalidArgument(_) => true
    _ => false
  }
  assert_true(rejected)
  let rejected = try {
    stream.seek(2)
    false
  } catch {
    @runtime.InvalidArgument(_) => true
    _ => false
  }
  assert_true(rejected)
  let rejected = try {
    let _ = stream.lookahead(0)
    false
  } catch {
    @runtime.InvalidArgument(_) => true
    _ => false
  }
  assert_true(rejected)
}

///|
test "token stream validation rejects missing or early EOF" {
  let tokens = @json.grammar().tokenize("null")
  let _ = tokens.pop()
  let rejected = try {
    let _ = @runtime.TokenStream::new(tokens)
    false
  } catch {
    @runtime.InvalidArgument(_) => true
    _ => false
  }
  assert_true(rejected)
  let reversed = @json.grammar().tokenize("null")
  let first = reversed[0]
  reversed[0] = reversed[1]
  reversed[1] = first
  let rejected = try {
    let _ = @runtime.TokenStream::new(reversed)
    false
  } catch {
    @runtime.InvalidArgument(_) => true
    _ => false
  }
  assert_true(rejected)
}
