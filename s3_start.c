#include <stdio.h>

__asm__(
    "entry:\n"
    "");

int test() {
}
int test_ret() {
    return 0;
}
int test_array() {
    int array[10];
    array[0] = 10;
    array[9] = 5;
    array[5] = array[0] * array[1 + 8];

    return array[5];
}

int function_c99(void) {
    printf("Hello, World!\n");

    return 0;
}
