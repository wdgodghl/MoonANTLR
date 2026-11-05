grammar Arithmetic;

document : expression EOF;
expression : term (('+' | '-') term)*;
term : factor (('*' | '/') factor)*;
factor : INT | '(' expression ')';
INT : [0-9]+;
WS : [ \t\r\n]+ -> skip;
