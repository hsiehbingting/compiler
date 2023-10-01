void main() {
    int i;
    int j;
    int isPrime;

    printf("Prime numbers between 1 and 1000:\n");

    for (i = 2; i <= 300; i=i+1) {
        isPrime = 1;

        j = 2;
        while (j < i) {
            if (i % j == 0) {
                isPrime = 0;
            }
            j=j+1;
        }

        if (isPrime!=0) {
            printf("%d\n", i);
        }
    }

}
