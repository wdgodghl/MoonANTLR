grammar LexActions;
@lexer::members {
    public final java.util.List<Integer> offsets = new java.util.ArrayList<>();
}
document : (LONG | SHORT | A | B | C | END)* EOF;
unit : LONG;
LONG : 'xy' {offsets.add(getCharIndex());} 'z' {offsets.add(getCharIndex());};
SHORT : 'x' {offsets.add(getCharIndex());};
A : 'a' {offsets.add(getCharIndex()); setText("A!"); setType(B);};
B : 'b';
C : 'mn' 'o';
END : EOF {offsets.add(getCharIndex());};
WS : [ \t\r\n]+ {offsets.add(getCharIndex());} -> skip;
