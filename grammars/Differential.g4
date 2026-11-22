grammar Differential;

document : expression EOF;
expression
  : <assoc=right> expression '^' expression
  | expression ('*' | '/') expression
  | expression ('+' | '-') expression
  | '-' expression
  | '(' expression ')'
  | ID
  | INT
  ;
choice : ('a' item 'b' | 'a' item 'c') EOF;
item : ('x' | 'y')*;
nullable : ('a' maybe 'b' | 'a' maybe) EOF;
maybe : 'x'?;
following : prefix 'x' EOF | prefix 'y' EOF;
prefix : ('a' | 'b')*;
ambiguous : (first | second) EOF;
first : ID;
second : ID;
reluctant : 'a' .*? ('b' | 'c') EOF;
contexts : ('a' inner 'b' | 'c' inner 'b' 'b') EOF;
inner : 'b' | ;
ID : [a-z]+;
INT : [0-9]+;
WS : [ \t\r\n]+ -> channel(HIDDEN);
