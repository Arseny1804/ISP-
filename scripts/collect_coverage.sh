#!/bin/bash
set -u

NGIRCD_BIN=~/protocol-fuzz/ngircd_coverage/src/ngircd/ngircd
CONF=~/protocol-fuzz/ngircd/fuzz/config/ngircd_6667.conf
REPLAY=~/protocol-fuzz/aflnet/aflnet-replay
LOG=/tmp/ngircd_coverage_server.log

echo "[*] Killing any leftover ngircd..."
pkill -9 -f "$NGIRCD_BIN" 2>/dev/null
sleep 1

echo "[*] Starting coverage-instrumented ngircd (log: $LOG)..."
"$NGIRCD_BIN" --nodaemon --config "$CONF" > "$LOG" 2>&1 &
NGIRCD_PID=$!
sleep 1

if ! kill -0 "$NGIRCD_PID" 2>/dev/null; then
  echo "[FAIL] ngircd did not start, check $LOG"
  exit 1
fi
echo "[*] ngircd started, PID=$NGIRCD_PID"

count=0
fail=0
for qdir in ~/protocol-fuzz/ngircd/fuzz/out_default/queue \
            ~/protocol-fuzz/ngircd/fuzz/out_custom/queue \
            ~/protocol-fuzz/ngircd/fuzz/out_parallel/master/queue \
            ~/protocol-fuzz/ngircd/fuzz/out_parallel/slave1/queue \
            ~/protocol-fuzz/ngircd/fuzz/out_parallel/slave2/queue \
            ~/protocol-fuzz/ngircd/fuzz/out_parallel/slave3/queue; do
  if [ -d "$qdir" ]; then
    for f in "$qdir"/id:*; do
      [ -f "$f" ] || continue
      "$REPLAY" "$f" IRC 6667 300 300 >/dev/null 2>&1
      rc=$?
      count=$((count+1))
      [ $rc -ne 0 ] && fail=$((fail+1))
      if [ $((count % 100)) -eq 0 ]; then
        echo "[*] progress: $count replayed so far ($(date +%H:%M:%S))"
      fi
    done
  fi
done

echo "[DONE] Total replayed: $count, failed(nonzero exit): $fail"

echo "[*] Gracefully stopping ngircd (SIGTERM)..."
kill -TERM "$NGIRCD_PID"
sleep 3

if kill -0 "$NGIRCD_PID" 2>/dev/null; then
  echo "[*] still alive, sending SIGINT..."
  kill -INT "$NGIRCD_PID"
  sleep 3
fi

if kill -0 "$NGIRCD_PID" 2>/dev/null; then
  echo "[WARN] ngircd still alive after SIGTERM+SIGINT, coverage may need manual check"
else
  echo "[OK] ngircd exited cleanly, .gcda should be flushed"
fi

echo "[*] Checking .gcda files..."
find ~/protocol-fuzz/ngircd_coverage/src/ngircd -name "*.gcda" | wc -l
