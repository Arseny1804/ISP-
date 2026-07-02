#include <unistd.h>
#include <string.h>
#include <stdint.h>
#include <stdio.h>

#define MAX_BUF 4096

/* ===== заглушка вместо реального FTP парсера ===== */
void ftp_parse(const unsigned char *buf, ssize_t len) {
    if (len <= 0) return;

    // простая имитация логики FTP (для покрытия)
    if (memmem(buf, len, "USER", 4)) {
        printf("USER handled\n");
    }

    if (memmem(buf, len, "PASS", 4)) {
        printf("PASS handled\n");
    }

    if (memmem(buf, len, "LIST", 4)) {
        printf("LIST handled\n");
    }

    if (memmem(buf, len, "CWD", 3)) {
        printf("CWD handled\n");
    }

    if (memmem(buf, len, "QUIT", 4)) {
        printf("QUIT handled\n");
    }
}

/* ===== main ===== */
int main() {
    unsigned char buf[MAX_BUF];
    ssize_t len;

    memset(buf, 0, sizeof(buf));

    /* читаем вход */
    len = read(0, buf, sizeof(buf));
    if (len <= 0) return 0;

    /* один прогон (для LCOV нам НЕ нужен AFL_LOOP) */
    ftp_parse(buf, len);

    return 0;
}
