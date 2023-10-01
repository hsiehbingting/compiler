lexer grammar mylexer;

options {
  language = Java;
}


/*----------------------*/
/*   Reserved Keywords  */
/*----------------------*/
INT_TYPE   : 'int';
CHAR_TYPE  : 'char';
LONG_TYPE  : 'long';
SHORT_TYPE : 'short';
VOID_TYPE  : 'void';
FLOAT_TYPE : 'float';
DOUBLE_TYPE: 'double';
SIGNED     : 'signed';
UNSIGNED   : 'unsigned';
TYPEDEF    : 'typedef';
STRUCT     : 'struct';
SIZEOF     : 'sizeof';
STATIC     : 'static';
AUTO       : 'auto';
GOTO       : 'goto';
DO         : 'do';
WHILE      : 'while';
IF         : 'if';
ELSE       : 'else';
FOR        : 'for';
SWITCH     : 'switch';
CASE       : 'case';
DEFAULT    : 'default';
CONST      : 'const';
DEFINE     : 'define';
BREAK      : 'break';
CONTINUE   : 'continue';
RETURN     : 'return';

/*----------------------*/
/*   func               */
/*----------------------*/
MAIN   : 'main';
SCANF  : 'scanf';
PRINTF : 'printf';
SQRT   : 'sqrt';

/*----------------------*/
/*  Compound Operators  */
/*----------------------*/

EQ_OP         : '==';
LE_OP         : '<=';
GE_OP         : '>=';
NE_OP         : '!=';
PP_OP         : '++';
MM_OP         : '--';
RS_A_OP       : '<<=';
LS_A_OP       : '>>='; 
RSHIFT_OP     : '<<';
LSHIFT_OP     : '>>';
GT_OP         : '>';
LT_OP         : '<';
PA_OP         : '+=';
SA_OP         : '-=';
MU_A_OP       : '*=';
MO_A_OP       : '%=';
DA_OP         : '/=';
PLUS_OP       : '+';
SUB_OP        : '-';
MULT_OP       : '*';
DIV_OP        : '/';
MOD_OP        : '%';
ASSIGN_OP     : '=';
LOG_AND_OP    : '&&';
LOG_OR_OP     : '||';
LOG_NOT_OP    : '!';
BIT_AND_A_OP  : '&=';
BIT_OR_A_OP   : '|=';
BIT_XOR_A_OP  : '^=';
COMPL_A_OP    : '~=';
BIT_AND_OP    : '&';
BIT_OR_OP     : '|';
BIT_XOR_OP    : '^';
COMPL_OP      : '~';

/*----------------------*/
/*   Delimiters         */
/*----------------------*/

COMMA         : ',' ;
SEMICOLON     : ';' ;
COLON         : ':' ;
PRE_PROCEssor : '#' ;
DOLLAR_SIGN   : '$' ;
LEFT_PAREN    : '(' ;
RIGHT_PAREN   : ')' ;
LEFT_BRACE    : '{' ;
RIGHT_BRACE   : '}' ;
LEFT_BRACKET  : '[' ;
RIGHT_BRACKET : ']' ;
QUES_MARK     : '?' ;


INCLUDE     : 'include';
HEADER_NAME
    : '<' (LETTER)(LETTER | DIGIT)* '.' (LETTER)(LETTER | DIGIT)* '>'
    ;

LITERAL : '"' (options{greedy=false;}: .)* '"';


DEC_NUM : ('0' | ('1'..'9')(DIGIT)*);

ID : (LETTER)(LETTER | DIGIT)*;

FLOAT_NUM: FLOAT_NUM1 | FLOAT_NUM2 ;
fragment FLOAT_NUM1: (DIGIT)+'.'(DIGIT)*;
fragment FLOAT_NUM2: '.'(DIGIT)+;

PERIOD : '.';

/* Comments */
COMMENT1 : '//'(.)*'\n' {skip();};
COMMENT2 : '/*' (options{greedy=false;}: .)* '*/' {skip();};




fragment LETTER : 'a'..'z' | 'A'..'Z' | '_';
fragment DIGIT : '0'..'9';


WS  : (' '|'\r'|'\t'|'\n')+ {skip();};
