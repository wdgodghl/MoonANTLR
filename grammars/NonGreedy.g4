grammar NonGreedy;
document : BLOCK EOF;
BLOCK : '/*' .*? '*/';
