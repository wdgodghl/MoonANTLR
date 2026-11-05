grammar Decisions;
document : item* EOF;
item
 : 'p' choice 'x' ';'
 | 'q' choice 'y' ';'
 | sequence ';'
 | longChoice ';'
 | either ';'
 ;
choice : 'a' # Short | 'a' 'x' # Long;
sequence : ID* ID;
longChoice : 'z' (ID+ '!' | ID+ '?');
either : first | second;
first : 'u';
second : 'u';
ID : [a-z]+;
WS : [ \t\r\n]+ -> skip;
