#include <stdio.h>

int max(int a, int b) {
    if (a > b) {
        return a;
    } else {
        return b;
    }
}

int main() {
    int a = -5, b = a-10/2, c = -15/-3;
    int d = max(a, b) && (c > b);
    switch (d) {
        case 0:
            printf("d is equal to 0\n");
            break;
        case 1:
            printf("d is equal to 1\n");
            break;
        default:
            printf("d is not equal to 0 or 1\n");
            break;
    }
    return 0;
}