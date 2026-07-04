#!/bin/bash
echo "=================================================================="
echo "         СРАВНЕНИЕ: default vs custom IRC mutator (30 min)"
echo "=================================================================="

for variant in default custom; do
  stats=~/protocol-fuzz/ngircd/fuzz/out_${variant}/fuzzer_stats
  echo ""
  echo "------------------- ${variant^^} -------------------"
  if [ -f "$stats" ]; then
    grep -E "^(execs_done|execs_per_sec|paths_total|paths_favored|unique_crashes|unique_hangs|bitmap_cvg|stability|cycles_done|max_depth)" "$stats"
  else
    echo "  [!] fuzzer_stats не найден по пути $stats"
  fi
done

echo ""
echo "=================================================================="
echo "Уникальные крэши/хэнги (файлы, если есть):"
echo "--- default ---"
find ~/protocol-fuzz/ngircd/fuzz/out_default/crashes -type f 2>/dev/null | grep -v README
find ~/protocol-fuzz/ngircd/fuzz/out_default/hangs -type f 2>/dev/null | grep -v README
echo "--- custom ---"
find ~/protocol-fuzz/ngircd/fuzz/out_custom/crashes -type f 2>/dev/null | grep -v README
find ~/protocol-fuzz/ngircd/fuzz/out_custom/hangs -type f 2>/dev/null | grep -v README
