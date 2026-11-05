grammar Typed;
document : entries+=entry (';' entries+=entry)* ';'? EOF;
entry : key=ID '=' value=expression note=ID?;
expression
 : <assoc=right> left=expression op='^' right=expression # Power
 | left=expression op=('*'|'/') right=expression # Product
 | left=expression op=('+'|'-') right=expression # Sum
 | '(' inner=expression ')' # Group
 | number=INT # Number
 ;
ID : [a-zA-Z]+;
INT : [0-9]+;
WS : [ \t\r\n]+ -> skip;
