lexer grammar StatefulLexer;
tokens { STRING }
OPEN : '"' {more(); pushMode(STR);};
END : '#' {setType(EOF);};
WORD : [a-z]+;
WS : [ \t\r\n]+ -> skip;
mode STR;
CLOSE : '"' {popMode(); setType(STRING);};
TEXT : ~["]+ -> more;
