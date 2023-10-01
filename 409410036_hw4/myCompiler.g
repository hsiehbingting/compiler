grammar myCompiler;

options {
   language = Java;
}

@header {

    import java.util.HashMap;
    import java.util.ArrayList;
}

@members {
    boolean TRACEON = false;

    public enum Type{
        ERR, BOOL, INT, FLOAT, CHAR, CONST_INT, VOID, SHORT, DOUBLE, LONG, CONST_FLOAT;
    }

    class tVar {
	    int   varIndex; // temporary variable's index. Ex: t1, t2, ..., etc.
	    int   iValue;   // value of constant integer. Ex: 123.
	    float fValue;   // value of constant floating point. Ex: 2.314.
        int   lIndex;
	};

    class Info {
        Type theType;  // type information.
        tVar theVar;
	   
	    Info() {
            theType = Type.ERR;
		    theVar = new tVar();
	   }
    };

	
    HashMap<String, Info> symtab = new HashMap<String, Info>();

    int labelCount = 0;
    int varCount = 0;
    int condCount = 0;
    int stringCount = 0;
    List<String> TextCode = new ArrayList<String>();

    void prologue()
    {
        // TextCode.add("; === prologue ===");
        TextCode.add("declare dso_local i32 @printf(i8*, ...)\n");
	    TextCode.add("define dso_local i32 @main()");
	    TextCode.add("{");
    }

    void epilogue()
    {
        /* handle epilogue */
        // TextCode.add("\n; === epilogue ===");
	    TextCode.add("ret i32 0");
        TextCode.add("}");
    }
    
    String newLabel()
    {
        labelCount ++;
        return (new String("L")) + Integer.toString(labelCount);
    } 
    
    public List<String> getTextCode()
    {
        return TextCode;
    }
}

program: VOID MAIN '(' ')'
        {
			prologue();

		}

        '{' 
            declarations
            statements
        '}'
        {
			if (TRACEON)
				System.out.println("VOID MAIN () {declarations statements}");
			epilogue();
        }
        ;


declarations: type Identifier 
        {
           if (TRACEON)
              System.out.println("declarations: type Identifier : declarations");

           if (symtab.containsKey($Identifier.text))
		   {
              // variable re-declared.
              System.out.println("Type Error: " + $Identifier.getLine() + ": Redeclared identifier.");
              System.exit(0);
           }
                 
           /* Add ID and its info into the symbol table. */
	       Info the_entry = new Info();
		   the_entry.theType = $type.attr_type;
		   the_entry.theVar.varIndex = varCount;
		   varCount ++;
		   symtab.put($Identifier.text, the_entry);

           // issue the instruction.
           if ($type.attr_type == Type.INT) {  // Ex: \%a = alloca i32, align 4
              TextCode.add("\%t" + the_entry.theVar.varIndex + " = alloca i32, align 4");
           }
           else if ($type.attr_type == Type.CHAR) { // Ex: \%a = alloca i8, align 1
              TextCode.add("\%t" + the_entry.theVar.varIndex + " = alloca i8, align 1");
           }
           else if ($type.attr_type == Type.FLOAT) { // Ex: \%a = alloca float, align 4
              TextCode.add("\%t" + the_entry.theVar.varIndex + " = alloca float, align 4");
           }
        }
         ';' declarations
        | 
        {
           if (TRACEON)
              System.out.println("declarations: ");
        }
        ;


type
returns [Type attr_type]
    : INT { if (TRACEON) System.out.println("type: INT"); $attr_type=Type.INT; }
    | CHAR { if (TRACEON) System.out.println("type: CHAR"); $attr_type=Type.CHAR; }
    | FLOAT {if (TRACEON) System.out.println("type: FLOAT"); $attr_type=Type.FLOAT; }
	;


statements:statement statements
          |
          ;


statement: assign_stmt ';'
         | if_else_stmt
        //  | func_no_return_stmt ';'
         | for_stmt
         | while_stmt
         | print_stmt
         ;

		 
cond_expression
returns [int condIndex]
               : l=arith_expression s=relation r=arith_expression
               {    
                    Info theLHS = $l.theInfo;        
                    Info theRHS = $r.theInfo;  

                    if ((theLHS.theType == Type.INT) &&
                       (theRHS.theType == Type.INT)) {		   

                        // Ex: \%cond = icmp sgt i32 \%t3, 0 
                        TextCode.add("\%cond"+ condCount +" = icmp " + s + " i32 \%t" + theLHS.theVar.varIndex + ", \%t" + theRHS.theVar.varIndex);
                        condIndex = condCount;
                        condCount++;

				    } else if ((theLHS.theType == Type.INT) &&
                               (theRHS.theType == Type.CONST_INT)) {		   

                        // Ex: \%cond = icmp sgt i32 \%t3, 0 
                        TextCode.add("\%cond"+ condCount +" = icmp " + s + " i32 \%t" + theLHS.theVar.varIndex + ", " + theRHS.theVar.iValue);
                        condIndex = condCount;
                        condCount++;

				    } else if ((theLHS.theType == Type.CONST_INT) &&
                               (theRHS.theType == Type.CONST_INT)) {		   

                        // Ex: \%cond = icmp sgt i32 \%t3, 0 
                        TextCode.add("\%cond"+ condCount +" = icmp " + s + " i32 " + theLHS.theVar.iValue + ", " + theRHS.theVar.iValue);
                        condIndex = condCount;
                        condCount++;

				    } else if ((theLHS.theType == Type.CONST_INT) &&
                               (theRHS.theType == Type.INT)) {		   

                        // Ex: \%cond = icmp sgt i32 \%t3, 0 
                        TextCode.add("\%cond"+ condCount +" = icmp " + s + " i32 " + theLHS.theVar.iValue + ", \%t" + theRHS.theVar.varIndex);
                        condIndex = condCount;
                        condCount++;

				    }

               }
               ;

relation
returns [String op]
    : '==' {op = "eq";}
    | '!=' {op = "ne";}
    | '>=' {op = "sge";}
    | '<=' {op = "sle";}
    | '<'  {op = "slt";}
    | '>'  {op = "sgt";}
    ;

if_else_stmt 
@init {Info theInfo = new Info();}
            : 
            {
                theInfo.theVar.lIndex = labelCount;
                labelCount++;
            }
              if_stmt[theInfo]
              else_stmt[theInfo]
            {
                TextCode.add("L" + theInfo.theVar.lIndex + "end:");
            }
            ; 

if_stmt[Info theInfo]
    : IF '(' a=cond_expression ')' 
    {    
        // br i1 \%cond, label \%Ltrue, label \%Lfalse
        TextCode.add("br i1 \%cond" + a + ", label \%L" + $theInfo.theVar.lIndex + "true, label \%L" + $theInfo.theVar.lIndex + "false");
        TextCode.add("L" + $theInfo.theVar.lIndex + "true:");
    }
        block_stmt
    {
        TextCode.add("br label \%L" + $theInfo.theVar.lIndex + "end");
        TextCode.add("L" + $theInfo.theVar.lIndex + "false:");
    }
    ;

else_stmt[Info theInfo]
    : ELSE block_stmt
        {TextCode.add("br label \%L" + $theInfo.theVar.lIndex + "end");}
    |   {TextCode.add("br label \%L" + $theInfo.theVar.lIndex + "end");}
    ;

	  
block_stmt: '{' statements '}'
	  ;


for_stmt
@init {Info theInfo = new Info();}
        : 
        {
            theInfo.theVar.lIndex = labelCount;
            labelCount++;
        }
        FOR '(' assign_stmt ';' 
        {
            TextCode.add("br label \%L" + theInfo.theVar.lIndex + "cond");
            TextCode.add("L" + theInfo.theVar.lIndex + "cond:");
        }
        a=cond_expression ';' 
        {
            TextCode.add("br i1 \%cond" + a + ", label \%L"+ theInfo.theVar.lIndex +"body, label \%L" + theInfo.theVar.lIndex + "end");
            // TextCode.add("br label \%L" + theInfo.theVar.lIndex + "body");
            TextCode.add("L" + theInfo.theVar.lIndex + "inc:");
        }
        assign_stmt ')'
        {
            TextCode.add("br label \%L" + theInfo.theVar.lIndex + "cond");
            TextCode.add("L" + theInfo.theVar.lIndex + "body:");
        }
        block_stmt
        {
            TextCode.add("br label \%L" + theInfo.theVar.lIndex + "inc");
            TextCode.add("L" + theInfo.theVar.lIndex + "end:");
        }      
        ;

while_stmt
@init {Info theInfo = new Info();}:
        {
            theInfo.theVar.lIndex = labelCount;
            labelCount++;
        }
        {
            TextCode.add("br label \%L" + theInfo.theVar.lIndex + "cond");
            TextCode.add("L" + theInfo.theVar.lIndex + "cond:");
        }
        WHILE '(' a=cond_expression ')' 
        {    
            // br i1 \%cond, label \%Ltrue, label \%Lfalse
            TextCode.add("br i1 \%cond" + a + ", label \%L" + theInfo.theVar.lIndex + "true, label \%L" + theInfo.theVar.lIndex + "false");
            TextCode.add("L" + theInfo.theVar.lIndex + "true:");
        }
        block_stmt
        {
            TextCode.add("br label \%L" + theInfo.theVar.lIndex + "cond");
            TextCode.add("L" + theInfo.theVar.lIndex + "false:");
        }
        ;


assign_stmt: Identifier '=' arith_expression
             {
                Info theRHS = $arith_expression.theInfo;
				Info theLHS = symtab.get($Identifier.text); 
		   
                if ((theLHS.theType == Type.INT) &&
                    (theRHS.theType == Type.INT)) {		   
                   // issue store insruction.
                   // Ex: store i32 \%tx, i32* \%ty
                   TextCode.add("store i32 \%t" + theRHS.theVar.varIndex + ", i32* \%t" + theLHS.theVar.varIndex + ", align 4");
				} else if ((theLHS.theType == Type.INT) &&
				    (theRHS.theType == Type.CONST_INT)) {
                   // issue store insruction.
                   // Ex: store i32 value, i32* \%ty
                   TextCode.add("store i32 " + theRHS.theVar.iValue + ", i32* \%t" + theLHS.theVar.varIndex + ", align 4");				
				}
			 }
             ;


print_stmt:
        'printf''('  STRING_LITERAL 
        //  @str = private unnamed_addr constant [13 x i8] c"Hello World\0A\00", align 1
        {
            // System.out.println($STRING_LITERAL.text);
            String str = $STRING_LITERAL.text.substring(1, $STRING_LITERAL.text.length() - 1)+"\\0A\\00"; 
            int strlen = $STRING_LITERAL.text.length();
            
            TextCode.add(stringCount,"@str" + stringCount + " = private unnamed_addr constant [" + strlen + " x i8] c\"" + str + "\", align 1" );
            
        // \%t4 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), i32 \%t3)
            String printline = "\%t" + varCount + " = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([" + strlen + " x i8], [" + strlen + " x i8]* @str" + stringCount + ", i64 0, i64 0)" ;
            varCount++;
            stringCount++;
        }
        
        (',' a=arg
        
        {
            if($a.theInfo.theType == Type.INT)
            {
                printline += ", i32 \%t" + $a.theInfo.theVar.varIndex;
            } 
            else if($a.theInfo.theType == Type.CONST_INT)
            {
                printline += ", i32 " + $a.theInfo.theVar.iValue;
            }
        }


        )* ')'';'
        {
            TextCode.add( printline + ")" );
        }

        ;


func_no_return_stmt: Identifier '(' argument ')'
                   ;


argument:  (',' arg)*
        ;

arg
returns [Info theInfo]
        : a=arith_expression {theInfo = $a.theInfo;}
        ;
		   

			   
arith_expression
returns [Info theInfo]
@init {theInfo = new Info();}
        : a=multExpr { $theInfo=$a.theInfo; } 
            ( '+' b=multExpr
            
            {				   
                if (($a.theInfo.theType == Type.INT) &&
                    ($b.theInfo.theType == Type.INT)) {
                    
                    TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
                
                    // Update arith_expression's theInfo.
                    $theInfo.theType = Type.INT;
                    $theInfo.theVar.varIndex = varCount;
                    varCount ++;
                } else if (($a.theInfo.theType == Type.INT) &&
                    ($b.theInfo.theType == Type.CONST_INT)) {

                    TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
                
                    // Update arith_expression's theInfo.
                    $theInfo.theType = Type.INT;
                    $theInfo.theVar.varIndex = varCount;
                    varCount ++;
                } else if (($a.theInfo.theType == Type.CONST_INT) &&
                    ($b.theInfo.theType == Type.CONST_INT)) {

                    TextCode.add("\%t" + varCount + " = add nsw i32 " + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);
                
                    // Update arith_expression's theInfo.
                    $theInfo.theType = Type.INT;
                    $theInfo.theVar.varIndex = varCount;
                    varCount ++;
                } else if (($a.theInfo.theType == Type.CONST_INT) &&
                    ($b.theInfo.theType == Type.INT)) {

                    TextCode.add("\%t" + varCount + " = add nsw i32 " + $theInfo.theVar.iValue + ", \%t" + $b.theInfo.theVar.varIndex);
                
                    // Update arith_expression's theInfo.
                    $theInfo.theType = Type.INT;
                    $theInfo.theVar.varIndex = varCount;
                    varCount ++;
                }
            }
            | '-' c=multExpr
            {				   
                if (($a.theInfo.theType == Type.INT) &&
                    ($c.theInfo.theType == Type.INT)) {
                    TextCode.add("\%t" + varCount + " = sub nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $c.theInfo.theVar.varIndex);
                
                    // Update arith_expression's theInfo.
                    $theInfo.theType = Type.INT;
                    $theInfo.theVar.varIndex = varCount;
                    varCount ++;
                } else if (($a.theInfo.theType == Type.INT) &&
                    ($c.theInfo.theType == Type.CONST_INT)) {
                    TextCode.add("\%t" + varCount + " = sub nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $c.theInfo.theVar.iValue);
                
                    // Update arith_expression's theInfo.
                    $theInfo.theType = Type.INT;
                    $theInfo.theVar.varIndex = varCount;
                    varCount ++;
                } else if (($a.theInfo.theType == Type.CONST_INT) &&
                    ($c.theInfo.theType == Type.CONST_INT)) {
                    TextCode.add("\%t" + varCount + " = sub nsw i32 " + $theInfo.theVar.iValue + ", " + $c.theInfo.theVar.iValue);
                
                    // Update arith_expression's theInfo.
                    $theInfo.theType = Type.INT;
                    $theInfo.theVar.varIndex = varCount;
                    varCount ++;
                } else if (($a.theInfo.theType == Type.CONST_INT) &&
                    ($c.theInfo.theType == Type.INT)) {
                    TextCode.add("\%t" + varCount + " = sub nsw i32 " + $theInfo.theVar.iValue + ", \%t" + $c.theInfo.theVar.varIndex);
                
                    // Update arith_expression's theInfo.
                    $theInfo.theType = Type.INT;
                    $theInfo.theVar.varIndex = varCount;
                    varCount ++;
                }
            }
            )*
            ;

multExpr
returns [Info theInfo]
@init {theInfo = new Info();}
          : a=signExpr { $theInfo=$a.theInfo; }
          ( '*' b=signExpr
		{			
 			if (($a.theInfo.theType == Type.INT) &&
				($b.theInfo.theType == Type.INT)) {
				TextCode.add("\%t" + varCount + " = mul nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			} else if (($a.theInfo.theType == Type.INT) &&
				($b.theInfo.theType == Type.CONST_INT)) {
				TextCode.add("\%t" + varCount + " = mul nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			} else if (($a.theInfo.theType == Type.CONST_INT) &&
				($b.theInfo.theType == Type.CONST_INT)) {
				TextCode.add("\%t" + varCount + " = mul nsw i32 " + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			} else if (($a.theInfo.theType == Type.CONST_INT) &&
				($b.theInfo.theType == Type.INT)) {
				TextCode.add("\%t" + varCount + " = mul nsw i32 " + $theInfo.theVar.iValue + ", \%t" + $b.theInfo.theVar.varIndex);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			}
		}		  
          | '/' c=signExpr
		{				   
			if (($a.theInfo.theType == Type.INT) &&
				($c.theInfo.theType == Type.INT)) {
				TextCode.add("\%t" + varCount + " = sdiv i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $c.theInfo.theVar.varIndex);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			} else if (($a.theInfo.theType == Type.INT) &&
				($c.theInfo.theType == Type.CONST_INT)) {
				TextCode.add("\%t" + varCount + " = sdiv i32 \%t" + $theInfo.theVar.varIndex + ", " + $c.theInfo.theVar.iValue);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			} else if (($a.theInfo.theType == Type.CONST_INT) &&
				($c.theInfo.theType == Type.CONST_INT)) {
				TextCode.add("\%t" + varCount + " = sdiv i32 " + $theInfo.theVar.iValue + ", " + $c.theInfo.theVar.iValue);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			} else if (($a.theInfo.theType == Type.CONST_INT) &&
				($c.theInfo.theType == Type.INT)) {
				TextCode.add("\%t" + varCount + " = sdiv i32 " + $theInfo.theVar.iValue + ", \%t" + $c.theInfo.theVar.varIndex);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			}
		}
          | '%' c=signExpr
		{				   
			if (($a.theInfo.theType == Type.INT) &&
				($c.theInfo.theType == Type.INT)) {
				TextCode.add("\%t" + varCount + " = srem i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $c.theInfo.theVar.varIndex);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			} else if (($a.theInfo.theType == Type.INT) &&
				($c.theInfo.theType == Type.CONST_INT)) {
				TextCode.add("\%t" + varCount + " = srem i32 \%t" + $theInfo.theVar.varIndex + ", " + $c.theInfo.theVar.iValue);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			} else if (($a.theInfo.theType == Type.CONST_INT) &&
				($c.theInfo.theType == Type.CONST_INT)) {
				TextCode.add("\%t" + varCount + " = srem i32 " + $theInfo.theVar.iValue + ", " + $c.theInfo.theVar.iValue);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			} else if (($a.theInfo.theType == Type.CONST_INT) &&
				($c.theInfo.theType == Type.INT)) {
				TextCode.add("\%t" + varCount + " = srem i32 " + $theInfo.theVar.iValue + ", \%t" + $c.theInfo.theVar.varIndex);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			}
		}
	  )*
	  ;

signExpr
returns [Info theInfo]
@init {theInfo = new Info();}
        : a=primaryExpr 
		{ 
			$theInfo=$a.theInfo; 
		} 
        | '-' b=primaryExpr
		{ 
			$theInfo=$b.theInfo; 
			if ($b.theInfo.theType == Type.INT) 
			{
				TextCode.add("\%t" + varCount + " = neg i32 \%t" + $theInfo.theVar.varIndex);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			} 
            else if ($b.theInfo.theType == Type.CONST_INT) {
				TextCode.add("\%t" + varCount + " = neg i32 " + $b.theInfo.theVar.iValue);
			
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
			}
		} 		
	;
		  
primaryExpr
returns [Info theInfo]
@init {theInfo = new Info();}
           : Integer_constant
	     {
            $theInfo.theType = Type.CONST_INT;
			$theInfo.theVar.iValue = Integer.parseInt($Integer_constant.text);
         }
           | Floating_point_constant
	     {
            $theInfo.theType = Type.CONST_FLOAT;
			$theInfo.theVar.fValue = Float.parseFloat($Floating_point_constant.text);
         }
           | Identifier
              {
                // get type information from symtab.
                Type the_type = symtab.get($Identifier.text).theType;
				$theInfo.theType = the_type;

                // get variable index from symtab.
                int vIndex = symtab.get($Identifier.text).theVar.varIndex;
				
                switch (the_type) {
                case INT: 
                         // get a new temporary variable and
						 // load the variable into the temporary variable.
                         
						 // Ex: \%tx = load i32, i32* \%ty.
						 TextCode.add("\%t" + varCount + " = load i32, i32* \%t" + vIndex);
				         
						 // Now, Identifier's value is at the temporary variable \%t[varCount].
						 // Therefore, update it.
						 $theInfo.theVar.varIndex = varCount;
						 varCount ++;
                         break;
                case FLOAT:
                         break;
                case CHAR:
                         break;
			
                }
              }
	   | '&' Identifier
	   | '(' arith_expression ')' { $theInfo=$arith_expression.theInfo; } 
           ;

		   
/* description of the tokens */
FLOAT:'float';
INT:'int';
CHAR: 'char';
LONG       : 'long';
SHORT      : 'short';
VOID       : 'void';
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
MAIN: 'main';

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

// RelationOP: '>' |'>=' | '<' | '<=' | '==' | '!=';

Identifier:('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*;
Integer_constant:'0'..'9'+;
Floating_point_constant:'0'..'9'+ '.' '0'..'9'* | '.' '0'..'9'+;

STRING_LITERAL
    :  '"' ( EscapeSequence | ~('\\'|'"') )* '"'
    ;




WS:( ' ' | '\t' | '\r' | '\n' ) {$channel=HIDDEN;};
// COMMENT:'/*' .* '*/' {$channel=HIDDEN;};
COMMENT1 : '//'(.)*'\n' {skip(); $channel=HIDDEN;};
COMMENT2 : '/*' (options{greedy=false;}: .)* '*/' {skip(); $channel=HIDDEN;};

fragment
EscapeSequence
    :   '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')
    ;
