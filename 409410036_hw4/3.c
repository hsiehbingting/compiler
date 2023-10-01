void main()
{
    int a;
    int b;
    int c;
    int i;
    int j;
    a = 70;
    b = 30;
    c = 40;
    i = 50;
    j = 60;
    if (a > b) 
    {
        printf("a is greater than b\n");
        if (a > c) 
        {
                printf("a is also greater than c\n");
        }
        for (i = 0; i < 5; i=i+1) 
        {
            printf("Iteration: %d\n", i);
            for (j = 0; j < 3; j=j+1) 
            {
                printf("Nested Iteration: %d\n", j);
            }
        }
    }
}