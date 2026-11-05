grammar Csv;
document : row (NL row)* EOF;
row : field (COMMA field)*;
field : TEXT | QUOTED | ;
COMMA : ',';
NL : '\r'? '\n';
QUOTED : '"' ('""' | ~["])* '"';
TEXT : ~[",\r\n]+;
