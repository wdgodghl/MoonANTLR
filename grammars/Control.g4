grammar Control;

document
@init {setErrorHandler(new BailErrorStrategy());}
  : 'a' 'b' EOF;

branch
@init {setErrorHandler(new BailErrorStrategy());}
  : ('a' 'b' | 'a' 'c') EOF;

toggle
@init {setBuildParseTree(false);}
  : left=child {setBuildParseTree(true);} right=child EOF;

child : 'a';

boundaries : 'a' empty 'b' EOF;
empty : ;
WS : [ \t\r\n]+ -> channel(HIDDEN);
