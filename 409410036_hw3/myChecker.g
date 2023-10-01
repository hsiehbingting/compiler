grammar myChecker;

@header {

    import java.util.HashMap;
}

@members {
    HashMap<String,TypeInfo> symtab = new HashMap<String,TypeInfo>();

    public enum TypeInfo {
        Integer(1),
		Float(2),
		Boolean(3),
		Unknown(0),
		No_Exist(-1),
		Error(-2);
    
		private final int value;

		private TypeInfo(int value) {
			this.value = value;
		}
	
		public int getValue() {
			return value;
		}
	}
    /* attr_type:
       1 => integer,
       2 => float,
       -1 => do not exist,
       -2 => error
     */	   
}

program: globalCompilationUnits mainFunction ;

globalCompilationUnits: includeLine globalCompilationUnits 
                    //   | declaration globalCompilationUnits 
                    //   | functionDec globalCompilationUnits 
                      | ;
includeLine: INCLUDE HEADER_NAME ;

mainFunction: VOID MAIN '(' ')' '{' localCompilationUnits '}';

localCompilationUnits: declaration localCompilationUnits  
                     | statement localCompilationUnits 
                     | ;


declaration
	: a=type Identifier 
     {
  	   if (symtab.containsKey($Identifier.text)) {
		   System.out.println("Error! " + 
				              $Identifier.getLine() + 
							  ": Redeclared identifier. " + 
							  "(" + $Identifier.text + ")");
	   } else {
		   /* Add ID and its attr_type into the symbol table. */
		   symtab.put($Identifier.text, $type.attr_type);	   
	   }
	 }
	 ('=' arith_expression
	 	{
			if ($type.attr_type != $arith_expression.attr_type) {
				System.out.println("Error! " + $arith_expression.start.getLine() +
									": Type mismatch for the two silde operands in an assignment statement. " +
									"(" + $type.attr_type + " and " + $arith_expression.attr_type + ")");
			}
		}
	 )?
	 ';' 
	;


type returns [TypeInfo attr_type]
	: INT   { $attr_type = TypeInfo.Integer; }
	| FLOAT { $attr_type = TypeInfo.Float; }
	;


arith_expression returns [TypeInfo attr_type]
	: a = multExpr { $attr_type = $a.attr_type; }
      ( '+' b = multExpr
	    { if ($a.attr_type != $b.attr_type) {
			  System.out.println("Error! " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the operator + in an expression. " +
								 "(" + $a.attr_type + " and " + $b.attr_type + ")");
		      $attr_type = TypeInfo.Error;
		  }
        }
	  | '-' c = multExpr
	  	{ if ($a.attr_type != $c.attr_type) {
			  System.out.println("Error! " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the operator - in an expression. " +
								 "(" + $a.attr_type + " and " + $c.attr_type + ")");
		      $attr_type = TypeInfo.Error;
		  }
        }
	  )*
	;

multExpr returns [TypeInfo attr_type]
	: a = signExpr { $attr_type = $a.attr_type; }
      ( '*' b = signExpr
	    { if ($a.attr_type != $b.attr_type) {
			  System.out.println("Error! " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the operator * in an expression. " +
								 "(" + $a.attr_type + " and " + $b.attr_type + ")");
		      $attr_type = TypeInfo.Error;
		  }
        }
	  | '/' c = signExpr
	  	{ if ($a.attr_type != $c.attr_type) {
			  System.out.println("Error! " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the operator / in an expression. " +
								 "(" + $a.attr_type + " and " + $c.attr_type + ")");
		      $attr_type = TypeInfo.Error;
		  }
        }
	  | '%' c = signExpr
	  	{ if ($a.attr_type != $c.attr_type) {
			  System.out.println("Error! " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the operator \% in an expression. " +
								 "(" + $a.attr_type + " and " + $c.attr_type + ")");
		      $attr_type = TypeInfo.Error;
		  }
        }
	  )*
	;

signExpr returns [TypeInfo attr_type]
	: primaryExpr { $attr_type = $primaryExpr.attr_type; }
	| '-' primaryExpr { $attr_type = $primaryExpr.attr_type; }
	;
		  
primaryExpr returns [TypeInfo attr_type] 
	: Integer_constant        { $attr_type = TypeInfo.Integer; }
	| Floating_point_constant { $attr_type = TypeInfo.Float; }
	| '(' arith_expression ')' { $attr_type = $arith_expression.attr_type; }
	| Identifier {
	   if (symtab.containsKey($Identifier.text)) {
	       $attr_type = symtab.get($Identifier.text);
	   } else {
           /* Add codes to report and handle this error */
           System.out.println("Error! " + $Identifier.getLine() + ": " + $Identifier.text + " undeclared");
	       $attr_type = TypeInfo.No_Exist;
		   return $attr_type;
	   }
	 }
    ;



logic_expression returns [TypeInfo attr_type]
	: a = andExpr { $attr_type = $a.attr_type; }
      ( '||' b = andExpr
	    { if ($a.attr_type != $b.attr_type) {
			  System.out.println("Error! " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the operator || in an expression. " +
								 "(" + $a.attr_type + " and " + $b.attr_type + ")");
		      $attr_type = TypeInfo.Error;
		  }
        }
	  )*
	;

andExpr returns [TypeInfo attr_type]
	: a = boolExpr { $attr_type = $a.attr_type; }
      ( '&&' b = boolExpr
	    { if ($a.attr_type != $b.attr_type) {
			  System.out.println("Error! " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the operator && in an expression. " +
								 "(" + $a.attr_type + " and " + $b.attr_type + ")");
		      $attr_type = TypeInfo.Error;
		  }
        }
	  )*
	;



boolExpr returns [TypeInfo attr_type]
	: a = arith_expression { $attr_type = $a.attr_type; }
      ( '<=' b = arith_expression
	    { if ($a.attr_type != $b.attr_type) {
			  System.out.println("Error! " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the operator <= in an expression. " +
								 "(" + $a.attr_type + " and " + $b.attr_type + ")");
		      $attr_type = TypeInfo.Error;
		  }
        }
	  | '>=' c = arith_expression
	    { if ($a.attr_type != $c.attr_type) {
			  System.out.println("Error! " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the operator >= in an expression. " +
								 "(" + $a.attr_type + " and " + $c.attr_type + ")");
		      $attr_type = TypeInfo.Error;
		  }
        }
	  | '<' d = arith_expression
	    { if ($a.attr_type != $d.attr_type) {
			  System.out.println("Error! " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the operator < in an expression. " +
								 "(" + $a.attr_type + " and " + $d.attr_type + ")");
		      $attr_type = TypeInfo.Error;
		  }
        }
	  | '>' e = arith_expression
	    { if ($a.attr_type != $e.attr_type) {
			  System.out.println("Error! " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the operator > in an expression. " +
								 "(" + $a.attr_type + " and " + $e.attr_type + ")");
		      $attr_type = TypeInfo.Error;
		  }
        }
	  |  '==' f = arith_expression
	    { if ($a.attr_type != $f.attr_type) {
			  System.out.println("Error! " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the operator == in an expression. " +
								 "(" + $a.attr_type + " and " + $f.attr_type + ")");
		      $attr_type = TypeInfo.Error;
		  }
        }
	  | '!=' g = arith_expression
	    { if ($a.attr_type != $g.attr_type) {
			  System.out.println("Error! " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the operator != in an expression. " +
								 "(" + $a.attr_type + " and " + $g.attr_type + ")");
		      $attr_type = TypeInfo.Error;
		  }
        }
	  ) {if ($attr_type == TypeInfo.Integer || $attr_type == TypeInfo.Float) $attr_type=TypeInfo.Boolean;}

	| '!' '(' h=logic_expression ')' {$attr_type=$h.attr_type;}
	;


statement returns [TypeInfo attr_type]
	: stmt_Assign ';' { $attr_type = $stmt_Assign.attr_type; }
	| if_statement else_if_statement else_statement
	| FOR '(' forAssign forExpr forIncr ')' then_statements
	| WHILE '(' condition ')' then_statements 
	| PRINTF '(' LITERAL (',' arith_expression)* ')' ';'
	;

stmt_AssignOP returns [String s]
	: '+='{s="+=";}|'-='{s="-=";}|'*='{s="*=";}|'/='{s="/=";}|'%='{s="\%=";};
stmt_IncrOP returns [String s]
	: '++'{s="++";}|'--'{s="--";};
stmt_Assign returns [TypeInfo attr_type]
	: Identifier '=' arith_expression {
	   if (symtab.containsKey($Identifier.text)) {
	       $attr_type = symtab.get($Identifier.text);
	   } else {
           /* Add codes to report and handle this error */
           System.out.println("Error! " + $arith_expression.start.getLine() + ": " + $Identifier.text + " undeclared");
	       $attr_type = TypeInfo.Error;
		   return $attr_type;
	   }
		
	   if ($attr_type != $arith_expression.attr_type) {
           System.out.println("Error! " + $arith_expression.start.getLine() +
						      ": Type mismatch for the two silde operands in an assignment statement. " +
							  "(" + $attr_type + " and " + $arith_expression.attr_type + ")");
		   $attr_type = TypeInfo.Error;
		   return $attr_type;
       }
	 }
	| Identifier stmt_AssignOP arith_expression {
	   if (symtab.containsKey($Identifier.text)) {
	       $attr_type = symtab.get($Identifier.text);
	   } else {
           /* Add codes to report and handle this error */
           System.out.println("Error! " + $arith_expression.start.getLine() + ": " + $Identifier.text + " undeclared");
	       $attr_type = TypeInfo.Error;
		   return $attr_type;
	   }
		
	   if ($arith_expression.attr_type != TypeInfo.Integer ) {
           System.out.println("Error! " + $arith_expression.start.getLine() +
						      ": Type after " + $stmt_AssignOP.s + " is not Integer. " +
							  "(" + $arith_expression.attr_type + ")");
		   $attr_type = TypeInfo.Error;
		//    return $attr_type;
       }

	   if (symtab.get($Identifier.text) != TypeInfo.Integer) {
           System.out.println("Error! " + $arith_expression.start.getLine() +
						      ": Type of " + $Identifier.text + " before " + $stmt_AssignOP.s + " is not Integer. " +
							  "(" + symtab.get($Identifier.text) + ")");
		   $attr_type = TypeInfo.Error;
		//    return $attr_type;
       }

	 }
	| Identifier stmt_IncrOP  
	 {
	   if (symtab.containsKey($Identifier.text)) {
	       $attr_type = symtab.get($Identifier.text);
	   } else {
           /* Add codes to report and handle this error */
           System.out.println("Error! " + $Identifier.getLine() + ": " + $Identifier.text + " undeclared");
	       $attr_type = TypeInfo.Error;
		   return $attr_type;
	   }
		
	   if (symtab.get($Identifier.text) != TypeInfo.Integer) {
           System.out.println("Error! " + $Identifier.getLine() +
						      ": Type of " + $Identifier.text + " after " + $stmt_IncrOP.s + " is not Integer. " +
							  "(" + symtab.get($Identifier.text) + ")");
		   $attr_type = TypeInfo.Error;
		//    return $attr_type;
       }

	 }
	| stmt_IncrOP  Identifier
	 {
	   if (symtab.containsKey($Identifier.text)) {
	       $attr_type = symtab.get($Identifier.text);
	   } else {
           /* Add codes to report and handle this error */
           System.out.println("Error! " + $Identifier.getLine() + ": " + $Identifier.text + " undeclared");
	       $attr_type = TypeInfo.Error;
		   return $attr_type;
	   }
		
	   if (symtab.get($Identifier.text) != TypeInfo.Integer) {
           System.out.println("Error! " + $Identifier.getLine() +
						      ": Type of " + $Identifier.text + " before " + $stmt_IncrOP.s + " is not Integer. " +
							  "(" + symtab.get($Identifier.text) + ")");
		   $attr_type = TypeInfo.Error;
		//    return $attr_type;
       }

	 }
	;

condition: logic_expression;
if_statement: IF '(' condition ')' then_statements ;
else_if_statement: (ELSE IF) => ELSE IF '(' condition ')' then_statements else_if_statement | ;
else_statement: (ELSE) => ELSE then_statements | ;
then_statements: '{' (statement|BREAK';'|CONTINUE';')* '}'
			   | statement
			   | BREAK';'
			   | CONTINUE';'
			   ;

// forAssign: declaration | ';';
forExpr: condition ';' ;    
forIncr: stmt_Assign | ; 
forAssign: 
	     (Identifier ('=' arith_expression {
	       if (!symtab.containsKey($Identifier.text)) {
               /* Add codes to report and handle this error */
               System.out.println("Error! " + $arith_expression.start.getLine() + ": " + $Identifier.text + " undeclared");

	       }
	    	
	       if (symtab.get($Identifier.text) != $arith_expression.attr_type) {
               System.out.println("Error! " + $arith_expression.start.getLine() +
	    					      ": Type mismatch for the two silde operands in an assignment statement. " +
	    						  "(" + symtab.get($Identifier.text) + " and " + $arith_expression.attr_type + ")");

           }
	     })?)? ';';

// statements
// 	: statement statements
// 	| ;



///////////////////////////////////////////////////////////

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
    : '<' Identifier '.' Identifier '>'
    ;

LITERAL : '"' (options{greedy=false;}: .)* '"';

// ID : (LETTER)(LETTER | DIGIT)*;


Identifier:('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*;
Integer_constant:'0'..'9'+;
Floating_point_constant:'0'..'9'+ '.' '0'..'9'* | '.' '0'..'9'+;

// FLOAT_NUM: FLOAT_NUM1 | FLOAT_NUM2 ;
// fragment FLOAT_NUM1: (DIGIT)+'.'(DIGIT)*;
// fragment FLOAT_NUM2: '.'(DIGIT)+;

PERIOD : '.';

/* Comments */
COMMENT1 : '//'(.)*'\n' {skip();};
COMMENT2 : '/*' (options{greedy=false;}: .)* '*/' {skip(); $channel=HIDDEN;};

fragment LETTER : 'a'..'z' | 'A'..'Z' | '_';
fragment DIGIT : '0'..'9';


WS  : (' '|'\r'|'\t'|'\n')+ {skip(); $channel=HIDDEN;};

