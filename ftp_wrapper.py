import sys
import socket
import time

HOST = "127.0.0.1"
PORT = 2121

def send(cmd):
    return cmd.encode() + b"\r\n"

with open(sys.argv[1], "rb") as f:
    data = f.read().decode(errors="ignore").splitlines()

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.settimeout(2)
s.connect((HOST, PORT))

try:
    # read banner
    print(s.recv(1024).decode(errors="ignore"))

    for line in data:
        if not line.strip():
            continue
        s.send(send(line))
        try:
            resp = s.recv(1024)
            if resp:
                pass
        except:
            pass

finally:
    s.close()
