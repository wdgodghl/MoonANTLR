parser grammar ModesParser;
options { tokenVocab=ModesLexer; }
document : (WORD | STRING | HASHED)* EOF;
