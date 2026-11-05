lexer grammar ModesLexer;
tokens { STRING, HASHED }
HIDDEN_OPEN : '@"' -> more, pushMode(HSTR);
OPEN : '"' -> more, pushMode(STR);
WORD : [a-zA-Z]+;
HASH : '#' [a-z]+ -> type(HASHED);
COMMENT : '//' ~[\r\n]* -> channel(HIDDEN);
WS : [ \t\r\n]+ -> skip;
mode STR;
CLOSE : '"' -> type(STRING), popMode;
TEXT : ~["\\]+ -> more;
ESCAPE : '\\' . -> more;
mode HSTR;
H_CLOSE : '"' -> type(STRING), channel(HIDDEN), popMode;
H_TEXT : ~["\\]+ -> more;
H_ESCAPE : '\\' . -> more;
