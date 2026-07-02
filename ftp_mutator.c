#include <stdlib.h>
#include <string.h>
#include <stdint.h>

static const char *cmds[] = {
    "USER anonymous\n",
    "PASS test@test.com\n",
    "PASS 1234\n",
    "LIST\n",
    "CWD /\n",
    "CWD ..\n",
    "QUIT\n"
};

#define NUM_CMDS (sizeof(cmds)/sizeof(cmds[0]))

// init
void *afl_custom_init(void *afl, unsigned int seed) {
    srand(seed);
    return NULL;
}

// REQUIRED in AFL++ 4.x
void afl_custom_deinit(void *data) {
    (void)data;
}

// fuzz function
size_t afl_custom_fuzz(void *data,
                        unsigned char *buf,
                        size_t buf_size,
                        unsigned char **out_buf,
                        unsigned char *add_buf,
                        size_t add_buf_size,
                        size_t max_size) {

    (void)data;
    (void)buf;
    (void)buf_size;
    (void)add_buf;
    (void)add_buf_size;

    static unsigned char tmp[4096];
    size_t pos = 0;

    int n = 2 + rand() % 6;

    for (int i = 0; i < n; i++) {
        const char *cmd = cmds[rand() % NUM_CMDS];
        size_t len = strlen(cmd);

        if (pos + len >= max_size) break;

        memcpy(tmp + pos, cmd, len);
        pos += len;
    }

    *out_buf = malloc(pos);
    memcpy(*out_buf, tmp, pos);

    return pos;
}
