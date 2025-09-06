#include <stdio.h>
#include <stdlib.h>

extern int my_strlen(const char *str);

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Error: this program must have 1 command line argument\n");
        return EXIT_FAILURE;
    }

    printf("The argument length is - %d\n", my_strlen(argv[1]));

    return 0;
}
