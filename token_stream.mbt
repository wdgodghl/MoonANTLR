///|
/// Buffered tokens with a physical cursor and channel-aware lookahead.
pub struct TokenStream {
  tokens : Array[Token]
  channel : Int32
  mut cursor : Int32
}

///|
fn TokenStream::on_channel(self : TokenStream, index : Int32) -> Int32 {
  let mut i = index
  while i < self.tokens.length() - 1 && self.tokens[i].channel != self.channel {
    i += 1
  }
  i
}

///|
/// Copy the buffer and require exactly one final EOF. EOF is visible on all channels.
pub fn TokenStream::new(
  tokens : Array[Token],
  channel~ : Int32 = 0,
) -> TokenStream raise RuntimeError {
  if tokens.is_empty() || channel < 0 {
    raise InvalidArgument(
      "nonempty token buffer and nonnegative channel required",
    )
  }
  for i in 0..<tokens.length() {
    let token = tokens[i]
    if token.kind == -1 {
      if i != tokens.length() - 1 {
        raise InvalidArgument("EOF must be the final token")
      }
    } else if token.kind <= 0 || i == tokens.length() - 1 {
      raise InvalidArgument("token buffer must end with EOF")
    }
    if token.start < 0 ||
      token.end < token.start ||
      token.line < 1 ||
      token.column < 0 ||
      token.channel < 0 {
      raise InvalidArgument("invalid token source coordinates or channel")
    }
  }
  let stream = TokenStream::{ tokens: tokens.copy(), channel, cursor: 0, }
  stream.cursor = stream.on_channel(0)
  stream
}

///|
/// The current index in the complete buffer, including hidden-channel tokens.
pub fn TokenStream::index(self : TokenStream) -> Int32 {
  self.cursor
}

///|
/// One-based lookahead; requests beyond the end return the final EOF token.
pub fn TokenStream::lookahead(
  self : TokenStream,
  offset : Int32,
) -> Token raise RuntimeError {
  if offset < 1 {
    raise InvalidArgument("lookahead is one-based")
  }
  let mut i = self.cursor
  let mut left = offset - 1
  while left > 0 && i < self.tokens.length() - 1 {
    i = self.on_channel(i + 1)
    left -= 1
  }
  self.tokens[i]
}

///|
pub fn TokenStream::consume(self : TokenStream) -> Unit raise RuntimeError {
  if self.tokens[self.cursor].kind == -1 {
    raise InvalidArgument("cannot consume EOF")
  }
  self.cursor = self.on_channel(self.cursor + 1)
}

///|
/// Seek a physical index and move forward to the next selected-channel token.
pub fn TokenStream::seek(
  self : TokenStream,
  index : Int32,
) -> Unit raise RuntimeError {
  if index < 0 || index >= self.tokens.length() {
    raise InvalidArgument("token index out of range")
  }
  self.cursor = self.on_channel(index)
}

///|
pub fn TokenStream::all_tokens(self : TokenStream) -> Array[Token] {
  self.tokens.copy()
}

///|
pub fn TokenStream::visible_tokens(self : TokenStream) -> Array[Token] {
  self.tokens.filter(token => token.channel == self.channel || token.kind == -1)
}
