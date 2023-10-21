#include <string.h>
#include <stdlib.h>
#include <stdio.h>

struct structure {
    int foo;
    union {
        int integer;
        char string[11];
        void *pointer;
    } node;
    short bar;
    long long baz;
    int array[7];
};
int main()
{
    int arr[] = {0x590ff23c, 0x2fbc5a4d, 0x636c6557, 0x20656d6f, 0x58206f74, 0x20545055,
                 0x6577202c, 0x6d6f636c, 0x6f742065, 0x79695820, 0x4c20756f, 0x78756e69,
                 0x6f724720, 0x5b207075, 0x33323032, 0x7825005d, 0x636c6557, 0x64fd6d1d};
    printf("%s", ((struct structure *)arr)->node.string,sizeof());
}