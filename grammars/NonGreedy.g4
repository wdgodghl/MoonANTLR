grammar NonGreedy;
document : (BLOCK | LONG | PLUS | WORD)* EOF;
LONG : '/*' [a-z]+ '*/!';
BLOCK : '/*' .*? '*/';
PLUS : '<' .+? '>';
WORD : [a-z]+;
WS : [ \t\r\n]+ -> skip;
