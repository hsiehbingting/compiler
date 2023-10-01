#include <stdio.h>
void main()
{
    int a = 2;
    int flag = 0;
    float b = 100.;
    int i;
    while(a<1000){
        flag = 0;
        for(i = 2; i < a; i++)
        {
            if(a%i==0)
            {
                flag = 1;
                break;
            }
        }
        if(flag==0)
            printf("%d\n",a);
        a++;
        Flag=0;
    }
    if(a==flag&&!(a>i||!(b<=i)))
    {
        a++;
    }

// Error! 21: Flag undeclared
// Error! 23: Type mismatch for the operator <= in an expression. (Float and Integer)
// Error! 23: Type mismatch for the operator || in an expression. (Boolean and Error)
// Error! 23: Type mismatch for the operator && in an expression. (Boolean and Error)
}
