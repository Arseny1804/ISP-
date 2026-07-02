#include <unistd.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>

#define MAX_BUF 4096

// ===== SIMPLE STATE RESET (IMPORTANT FOR AFL) =====
static void ftp_reset_state() {
    // здесь можно расширять (если появится state)
}

// ===== CUSTOM MUTATION =====
static void ftp_mutate(uint8_t *buf, ssize_t *len) {

    for (int i = 0; i < *len; i++) {

        // нормализуем FTP команды (case-insensitive fuzzing)
        if (buf[i] >= 'a' && buf[i] <= 'z') {
            buf[i] -= 32;
        }

        // заменяем странные пробелы на перенос строки (усиливает parser branches)
        if (buf[i] == '\t') {
            buf[i] = ' ';
        }
    }
}

int main() {

    unsigned char buf[MAX_BUF];
    ssize_t len;

#ifdef __AFL_HAVE_MANUAL_CONTROL
    __AFL_INIT();
#endif

    while (__AFL_LOOP(1000)) {

        memset(buf, 0, sizeof(buf));

        len = read(0, buf, sizeof(buf));
        if (len <= 0) break;

        ftp_reset_state();

        ftp_mutate(buf, &len);

        ftp_parse(buf, len);
    }

    return 0;
}
