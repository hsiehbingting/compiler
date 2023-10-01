#include <stdio.h>

int main() {
    float array[5], pi = 3.14159;
    printf("Enter 5 floating-point numbers:\n");
    for (int i = 0; i < 5; i++) {   /* scanf */
        scanf("%f", &array[i]);
    }
    printf("The array elements are: ");
    for (int i = 0; i < 5; i++) {   // print
        printf("%.2f ", array[i]);
    }
    printf("\n");
    for (int i = 0; i < 5; i++) {
        if (array[i] < 0) {
            printf("Skipping negative element %.2f\n", array[i]);
            continue;
        }
        printf("The square of %.2f is %.2f\n", array[i], array[i] * array[i]);
    }
    return 0;
}