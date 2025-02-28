#include "user/user.h"

int main (int argc, char* argv[]) {
    if (argc < 3) {
        exit(0);
    }

    int mask = atoi(argv[1]);
    trace(mask);

    exec(argv[2], &argv[2]);
    exit(0);
}