#include <stdio.h>
void main(){
    int a = 1;
    float b = 1.;
    float c = 2.;
    if(a<1)
        if(a*a>2)
            printf("1\n");
        else
            printf("2\n");
    else if(a<2)
        if(a-a<3)
            printf("3\n");
        else
            printf("4\n");
    else if(a<3)
        if(a-2>3.5)
            printf("5\n");
        else
            printf("6\n");
    else if(a/2.0==b)
        if(a+.1<4)
            printf("7\n");
        else
            printf("8\n");
    else if(3<4&&4<5)
        printf("9\n");
    else
        printf("a=%d,b=%d,b+c=%f",a,b,b+c);

// Error! 17: Type mismatch for the operator > in an expression. (Integer and Float)
// Error! 21: Type mismatch for the operator / in an expression. (Integer and Float)
// Error! 21: Type mismatch for the operator == in an expression. (Error and Float)
// Error! 22: Type mismatch for the operator + in an expression. (Integer and Float)
// Error! 22: Type mismatch for the operator < in an expression. (Error and Integer)

}
