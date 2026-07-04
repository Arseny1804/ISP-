#!/bin/bash
set -e

AFLNET=~/protocol-fuzz/aflnet/afl-fuzz
NGIRCD=~/protocol-fuzz/ngircd/src/ngircd/ngircd
SEEDS=~/protocol-fuzz/ngircd/fuzz/seeds
OUT=~/protocol-fuzz/ngircd/fuzz/out_parallel
CONF_DIR=~/protocol-fuzz/ngircd/fuzz/config

COMMON="-P IRC -D 10000 -q 3 -s 3 -E -K -R -m none"

pkill -9 ngircd 2>/dev/null || true
sleep 1

tmux kill-session -t fuzz_parallel 2>/dev/null || true
tmux new-session -d -s fuzz_parallel -n main
tmux split-window -h -t fuzz_parallel:main
tmux split-window -v -t fuzz_parallel:main.0
tmux split-window -v -t fuzz_parallel:main.1

tmux send-keys -t fuzz_parallel:main.0 "AFL_OLD_FORKSERVER=1 $AFLNET -i $SEEDS -o $OUT -M master -N tcp://127.0.0.1/6667 $COMMON -- $NGIRCD --nodaemon --config $CONF_DIR/ngircd_6667.conf" C-m
sleep 3
tmux send-keys -t fuzz_parallel:main.1 "AFL_OLD_FORKSERVER=1 $AFLNET -i $SEEDS -o $OUT -S slave1 -N tcp://127.0.0.1/6668 $COMMON -- $NGIRCD --nodaemon --config $CONF_DIR/ngircd_6668.conf" C-m
tmux send-keys -t fuzz_parallel:main.2 "AFL_OLD_FORKSERVER=1 $AFLNET -i $SEEDS -o $OUT -S slave2 -N tcp://127.0.0.1/6669 $COMMON -- $NGIRCD --nodaemon --config $CONF_DIR/ngircd_6669.conf" C-m
tmux send-keys -t fuzz_parallel:main.3 "AFL_OLD_FORKSERVER=1 $AFLNET -i $SEEDS -o $OUT -S slave3 -N tcp://127.0.0.1/6670 $COMMON -- $NGIRCD --nodaemon --config $CONF_DIR/ngircd_6670.conf" C-m

echo "Started. Attach with: tmux attach -t fuzz_parallel"
