grammar Precedence;
document : expression EOF;
expression
 : <assoc=right> expression '^' expression
 | expression ('*'|'/') expression
 | expression ('+'|'-') expression
 | '-' expression
 | '(' expression ')'
 | INT
 ;
INT : [0-9]+;
WS : [ \t\r\n]+ -> skip;
