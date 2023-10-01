#include <stdio.h>
void main()
{
    int a = 1;
    float b = 100.;
    int c;
    float d = a;
    int a = 0;
    for(a = 0; a < b; a++)
        for(c = 0; c < a||c==a; c=c+1)
        {
            if(a%2!=1||c%2==1){
                a++;
                b--;
            }
            printf("a=%d,b=%f,c=%f,a*c=%f,b/c=%f\n",a,b,c,a*c,b/c);
            printf("e=%d",e);
        }

// Error! 7: Type mismatch for the two silde operands in an assignment statement. (Float and Integer)
// Error! 8: Redeclared identifier. (a)
// Error! 9: Type mismatch for the operator < in an expression. (Integer and Float)
// Error! 14: Type of b after -- is not Integer. (Float)
// Error! 16: Type mismatch for the operator / in an expression. (Float and Integer)
// Error! 17: e undeclared

}
        
