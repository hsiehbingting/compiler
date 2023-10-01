grammar myparser;

options {
   language = Java;
}

@header {
    // import packages here.

}

@members {
    boolean TRACEON = true;
    boolean UNIT_TRACEON = false;
    int n = 0; // "\t".repeat(n)+ // {n++;} // {n--;}

//{L();} //{R();}
    public void L() {   
        System.out.print("(");

    }
    public void R() {
        System.out.print(")");

    }
    public void P(String s) {
        System.out.print(s);

    }
}

program: { if (TRACEON) System.out.println("\t".repeat(n)+"program: globalCompilationUnits mainFunction");} 
          globalCompilationUnits mainFunction ;

globalCompilationUnits: { if (TRACEON&&UNIT_TRACEON) System.out.println("\t".repeat(n)+"globalCompilationUnits: includeLine globalCompilationUnits");} 
                         includeLine globalCompilationUnits 

                      | { if (TRACEON&&UNIT_TRACEON) System.out.println("\t".repeat(n)+"globalCompilationUnits: declaration globalCompilationUnits");} 
                         declaration globalCompilationUnits 

                      | { if (TRACEON&&UNIT_TRACEON) System.out.println("\t".repeat(n)+"globalCompilationUnits: functionDec globalCompilationUnits");}
                         functionDec globalCompilationUnits 

                      | { if (TRACEON&&UNIT_TRACEON) System.out.println("\t".repeat(n)+"globalCompilationUnits:");} ;

includeLine: { if (TRACEON) System.out.println("\t".repeat(n)+"includeLine: INCLUDE HEADER_NAME");} 
              INCLUDE HEADER_NAME ;

declaration: { if (TRACEON) System.out.println("\t".repeat(n)+"declaration: type idList ;");} 
              type idList ';' ;

functionDec: { if (TRACEON) System.out.println("\t".repeat(n)+"functionDec: type ID ( parametersDec ) {localCompilationUnits}");} 
              type ID '(' parametersDec ')' {n++;}'{' localCompilationUnits '}'{n--;} ;

idList: { if (TRACEON) System.out.println("\t".repeat(n)+"idList: ID(=expr)? (, ID(=expr)?)*");}
         ID('=' {P("\t".repeat(n)+"expr: ");} expr {P("\n");} )? (','ID('=' {P("\t".repeat(n)+"expr: ");} expr {P("\n");} )? )* ;

parametersDec: { if (TRACEON) System.out.println("\t".repeat(n)+"parametersDec: type ID (=expr)? (, type ID (=expr)?)*");}
                type ID ('=' {P("\t".repeat(n)+"expr: ");} expr {P("\n");} )? (','type ID ('=' {P("\t".repeat(n)+"expr: ");} expr {P("\n");} )?)*      
                          
             | { if (TRACEON) System.out.println("\t".repeat(n)+"parametersDec:"); };


mainFunction: { if (TRACEON) System.out.println("\t".repeat(n)+"mainFunction: type MAIN () { localCompilationUnits }");} 
               type MAIN '(' ')' {n++;}'{' localCompilationUnits'}'{n--;} ;


localCompilationUnits: { if (TRACEON&&UNIT_TRACEON) System.out.println("\t".repeat(n)+"localCompilationUnits: statement localCompilationUnits"); } 
                        statement localCompilationUnits  

                     | { if (TRACEON&&UNIT_TRACEON) System.out.println("\t".repeat(n)+"localCompilationUnits: declaration localCompilationUnits"); } 
                        declaration localCompilationUnits 

                     | { if (TRACEON&&UNIT_TRACEON) System.out.println("\t".repeat(n)+"localCompilationUnits:"); };


type: INT      {if (TRACEON) System.out.println("\t".repeat(n)+"type: INT"); }
    | FLOAT    {if (TRACEON) System.out.println("\t".repeat(n)+"type: FLOAT"); }
    | CHAR     {if (TRACEON) System.out.println("\t".repeat(n)+"type: CHAR"); }
    | LONG     {if (TRACEON) System.out.println("\t".repeat(n)+"type: LONG"); }
    | SHORT    {if (TRACEON) System.out.println("\t".repeat(n)+"type: SHORT"); }
    | DOUBLE   {if (TRACEON) System.out.println("\t".repeat(n)+"type: DOUBLE"); }
    | VOID     {if (TRACEON) System.out.println("\t".repeat(n)+"type: VOID"); }
    | SIGNED   {if (TRACEON) System.out.println("\t".repeat(n)+"type: SIGNED"); }
    | UNSIGNED {if (TRACEON) System.out.println("\t".repeat(n)+"type: UNSIGNED"); };

//{L();} //{R();} //{P("");}
expr: orExpr expr2 ;
expr2: assignOP {L();} orExpr {R();}
     | ;


orExpr:  andExpr orExpr2 ;
orExpr2: '||' {P("||");}{L();} andExpr  {R();}orExpr2
       | ;

andExpr: bitOrExpr andExpr2 ;
andExpr2: '&&' {P("&&");}{L();} bitOrExpr  {R();}andExpr2
        | ;

bitOrExpr: bitXorExpr bitOrExpr2 ;
bitOrExpr2: '|' {P("|");}{L();} bitXorExpr  {R();}bitOrExpr2
          | ;

bitXorExpr: bitAndExpr bitXorExpr2 ;
bitXorExpr2: '^'{P("^");}{L();} bitAndExpr  {R();}bitXorExpr2
           | ;


bitAndExpr: equalExpr bitAndExpr2 ;
bitAndExpr2: '&' {L();}equalExpr {R();}bitAndExpr2
           | ;

equalExpr: relationExpr equalExpr2;
equalExpr2: '=='{P("==");}{L();} relationExpr  {R();}equalExpr2
          | '!='{P("!=");}{L();} relationExpr  {R();}equalExpr2
          | ;

relationExpr: bitShiftExpr relationExpr2 ;
relationExpr2: '<='{P("<=");}{L();} bitShiftExpr {R();}relationExpr2
             | '>=' {P(">=");}{L();}bitShiftExpr {R();}relationExpr2
             | '<' {P("<");}{L();}bitShiftExpr {R();}relationExpr2
             | '>'{P(">");}{L();} bitShiftExpr {R();}relationExpr2
             | ;

bitShiftExpr: addExpr bitShiftExpr2 ;
bitShiftExpr2: '<<'{P("<<");}{L();} addExpr {R();}bitShiftExpr2
             | '>>'{P(">>");}{L();} addExpr {R();}bitShiftExpr2
             | ;

addExpr: multExpr addExpr2 ;
addExpr2: '+'{P("+");}{L();} multExpr{R();}addExpr2
        | '-'{P("-");}{L();} multExpr{R();}addExpr2
        | ;


multExpr: primary2Expr multExpr2 ;
multExpr2: '*'{P("*");}{L();} primary2Expr{R();}multExpr2
         | '/'{P("/");}{L();} primary2Expr{R();}multExpr2
         | '%'{P("\%");}{L();} primary2Expr{R();}multExpr2
         | ;

primary2Expr: primaryExpr
            | {L();}'-'{P("-");}{L();} primaryExpr {R();}{R();};


primaryExpr: INT_NUM {P("INT_NUM");}
           | FLOAT_NUM {P("FLOAT_NUM");}
           | ID {P("ID");}
           | '++' ID {P("(++ID)");}
           | '--' ID {P("(--ID)");}
           | ID '--' {P("(ID--)");}
           | ID '++' {P("(ID++)");}
           | {L();} '('orExpr')' {R();}
           |  {P("func: ");} func ;

func: {L();} {P("ID ");} ID {L();} '(' {P("parameters: ");} {L();} parameters {R();} ')' {R();} {R();};
parameters: parameter ({P(", ");} ',' parameter)* 
          | ;
parameter: {P("expr: ");} {L();}expr{R();};

////////////////////////////////////////////
// {P("\t".repeat(n)+"expr: ");} // {P("\n");}
statement: { if (TRACEON) System.out.println("\t".repeat(n)+"statement: expr ;");} 
           { P("\t".repeat(n)+"expr: ");} expr {P("\n");} ';'                  

         | { if (TRACEON) System.out.println("\t".repeat(n)+"statement: BREAK ;");}
            BREAK ';'                 
            
         | { if (TRACEON) System.out.println("\t".repeat(n)+"statement: CONTINUE ;");}
            CONTINUE ';'              

         | { if (TRACEON) System.out.println("\t".repeat(n)+"statement: RETURN expr? ;");} 
            RETURN  ({P("\t".repeat(n)+"expr: ");}expr{P("\n");})?  ';'

         | { if (TRACEON) System.out.println("\t".repeat(n)+"statement: if_statement else_if_statement else_statement");} 
            if_statement else_if_statement else_statement                                

         | { if (TRACEON) System.out.println("\t".repeat(n)+"statement: FOR (forAssign; forExpr; forIncr) {localCompilationUnits}");} 
            FOR '(' forAssign ';' forExpr ';' forIncr ')' {n++;}'{' localCompilationUnits '}'{n--;}  

         | { if (TRACEON) System.out.println("\t".repeat(n)+"statement: WHILE (expr) {localCompilationUnits}");} 
            WHILE '(' {P("\t".repeat(n)+"expr: ");} expr {P("\n");} ')' {n++;}'{'localCompilationUnits'}'{n--;}                               

         | { if (TRACEON) System.out.println("\t".repeat(n)+"statement: PRINTF (LITERAL (, expr)* ) ;");} 
            PRINTF '(' LITERAL (',' {P("\t".repeat(n)+"expr: ");} expr {P("\n");} )* ')' ';'                                       

         | { if (TRACEON) System.out.println("\t".repeat(n)+"statement: SCANF (LITERAL (,(&)?ID)* ) ;");} 
            SCANF '(' LITERAL (','('&')?ID)* ')' ';' ;

if_statement: { if (TRACEON) System.out.println("\t".repeat(n)+"if_statement: IF (expr) { localCompilationUnits }");}
               IF '(' {P("\t".repeat(n)+"expr: ");} expr {P("\n");} ')'{n++;}'{' localCompilationUnits '}'{n--;} ;

else_if_statement: {if (TRACEON) System.out.println("\t".repeat(n)+"else_if_statement: ELSE IF (expr) {localCompilationUnits} else_if_statement");}
                    ELSE IF '(' {P("\t".repeat(n)+"expr: ");} expr {P("\n");} ')' {n++;}'{' localCompilationUnits '}'{n--;} else_if_statement 

                 | {if (TRACEON) System.out.println("\t".repeat(n)+"else_if_statement:");};

else_statement: {if (TRACEON) System.out.println("\t".repeat(n)+"else_statement: ELSE {localCompilationUnits}");}
                 ELSE {n++;}'{' localCompilationUnits '}'{n--;} 

              | {if (TRACEON) System.out.println("\t".repeat(n)+"else_statement:");};


forAssign: {if (TRACEON) System.out.println("\t".repeat(n)+"forAssign: type ID (assignOP expr)?");}
            type ID ('=' {P("\t".repeat(n)+"expr: ");} expr {P("\n");} )? 

         | {if (TRACEON) System.out.println("\t".repeat(n)+"forAssign:");};

forExpr: {if (TRACEON) System.out.println("\t".repeat(n)+"forExpr: expr");}
         {P("\t".repeat(n)+"expr: ");} expr {P("\n");}    

       | { if (TRACEON) System.out.println("\t".repeat(n)+"statement:");};

forIncr: {if (TRACEON) System.out.println("\t".repeat(n)+"forIncr: expr");}
         {P("\t".repeat(n)+"expr: ");} expr {P("\n");}   

       | {if (TRACEON) System.out.println("\t".repeat(n)+"forIncr:");};

assignOP: ASSIGN_OP     {P("= ");}
        | RS_A_OP       {P("<<=");}
        | LS_A_OP       {P(">>=");}
        | PA_OP         {P("+= ");}
        | SA_OP         {P("-= ");}
        | MU_A_OP       {P("*= ");}
        | MO_A_OP       {P("\%=");}
        | DA_OP         {P("/= ");}
        | BIT_AND_A_OP  {P("&= ");}
        | BIT_OR_A_OP   {P("|= ");}
        | BIT_XOR_A_OP  {P("^= ");}
        | COMPL_A_OP    {P("~= ");};


/* description of the tokens */
/*----------------------*/
/*   Reserved Keywords  */
/*----------------------*/
INT        : 'int';
CHAR       : 'char';
LONG       : 'long';
SHORT      : 'short';
VOID       : 'void';
FLOAT      : 'float';
DOUBLE     : 'double';
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


INCLUDE : '#include';
HEADER_NAME
    : '<' ID '.' ID '>'
    ;

LITERAL : '"' (options{greedy=false;}: .)* '"';


INT_NUM : ('0' | ('1'..'9')(DIGIT)*);

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
