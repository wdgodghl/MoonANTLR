lexer grammar OptionsLexer;
options { caseInsensitive = true; }
channels { COMMENTS }
tokens { ALIAS }
WORD : LETTER+;
fragment LETTER : [a-z];
COMMA : ',' -> type(ALIAS);
COMMENT : '//' ~[\r\n]* -> channel(COMMENTS);
WS : [ \t\r\n]+ -> skip;
