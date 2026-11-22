grammar SemanticDifferential;

@parser::members {
  boolean enabled = Boolean.getBoolean("moonantlr.semanticFlag");
  boolean pred(int tag, boolean value) {
    System.out.print(tag + ":");
    return value;
  }
}

entry : (left | right) EOF;
left : {pred(1, enabled)}? ID;
right : {pred(2, !enabled)}? ID;
combined : ({pred(3, enabled)}? {pred(4, true)}? ID | {pred(5, !enabled)}? ID) EOF;
local : (('a' | 'b') {pred(6, _input.LT(1).getText().equals("foo"))}? ID | ('a' | 'b') ID) EOF;
parameterized : child[1] child[-1] EOF;
child[int n] : {pred(7, $n > 0)}? ID | {pred(8, $n < 0)}? INT;
ID : [a-z]+;
INT : [0-9]+;
WS : [ \t\r\n]+ -> channel(HIDDEN);
