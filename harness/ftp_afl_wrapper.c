#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

#define PORT 2121
#define HOST "127.0.0.1"

void send_cmd(int sock, const char *cmd) {
    send(sock, cmd, strlen(cmd), 0);
    send(sock, "\r\n", 2, 0);
}

int main(int argc, char **argv) {
    char buffer[4096];

    printf("[+] start wrapper\n");
    fflush(stdout);

    int len = read(0, buffer, sizeof(buffer) - 1);
    if (len <= 0) {
        printf("[-] no input\n");
        return 0;
    }

    buffer[len] = 0;

    char *cmd = strtok(buffer, ";");

    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        printf("[-] socket failed\n");
        return 0;
    }

    struct sockaddr_in serv;
    serv.sin_family = AF_INET;
    serv.sin_port = htons(PORT);
    inet_pton(AF_INET, HOST, &serv.sin_addr);

    if (connect(sock, (struct sockaddr*)&serv, sizeof(serv)) < 0) {
        printf("[-] connect failed\n");
        return 0;
    }

    printf("[+] connected\n");
    fflush(stdout);

    // FTP session start
    send_cmd(sock, "USER anonymous");
    send_cmd(sock, "PASS test");

    while (cmd != NULL) {
        send_cmd(sock, cmd);
        cmd = strtok(NULL, ";");
    }

    send_cmd(sock, "QUIT");

    close(sock);

    printf("[+] done\n");
    fflush(stdout);

    return 0;
}
