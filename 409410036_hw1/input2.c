#include <stdio.h>

int main() {
    int a = 3, b = 5;
    int c = 1;
    while (a > 0) {
        c *= b;
        a--;
    }
    printf("c = %d\n", c);
    int d = c | 16;
    printf("d = %x\n", d);
    int e = d << 2;
    printf("e = %x\n", e);
    return 0;
}