grammar Recursion;
document : expression EOF;
expression
 : expression '!'
 | expression '*' expression
 | expression '+' expression
 | <assoc=right> expression '?' expression ':' expression
 | '-' expression
 | INT ('[' expression ']')*
 | '(' expression ')'
 ;
INT : [0-9]+;
WS : [ \t\r\n]+ -> skip;
