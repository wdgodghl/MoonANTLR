lexer grammar UnicodeModesLexer;

tokens { STRING }
ID : LETTER (LETTER | DIGIT)*;
INT : DIGIT+;
fragment LETTER : [a-zA-Z_\u0080-\uFFFF] | [\u{10000}-\u{10FFFF}];
fragment DIGIT : [0-9];
OPEN : '"' -> more, pushMode(QUOTED);
COMMENT : '/*' .*? '*/' -> channel(HIDDEN);
LINE : '//' ~[\r\n]* -> skip;
WS : [ \t\r\n]+ -> channel(HIDDEN);

mode QUOTED;
CLOSE : '"' -> type(STRING), popMode;
ESCAPE : '\\' . -> more;
TEXT : ~["\\]+ -> more;
