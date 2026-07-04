#!/bin/bash
# Одиночный запуск AFLNet против ngIRCd (протокол IRC, наш кастомный модуль)
set -e
AFLNET_BIN=${1:-../aflnet/afl-fuzz}
NGIRCD_BIN=${2:-../ngircd/src/ngircd/ngircd}
CONF=${3:-config/ngircd_template.conf}
OUT=${4:-out}

AFL_OLD_FORKSERVER=1 "$AFLNET_BIN" \
  -i seeds \
  -o "$OUT" \
  -N tcp://127.0.0.1/6667 \
  -P IRC \
  -D 10000 \
  -q 3 -s 3 \
  -E -K -R \
  -m none \
  -- "$NGIRCD_BIN" --nodaemon --config "$CONF"
