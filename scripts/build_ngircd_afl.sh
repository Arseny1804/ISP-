#!/bin/bash
# Пересборка ngIRCd с инструментацией AFL++ (классический режим,
# совместимый с форк-сервером AFLNet 2.56b)
set -e
cd ngircd  # клонированный https://github.com/ngircd/ngircd.git
make distclean 2>/dev/null || true
AFL_LLVM_INSTRUMENT=CLASSIC CC=afl-clang-fast ./configure
AFL_LLVM_INSTRUMENT=CLASSIC CC=afl-clang-fast make -j$(nproc)
echo "Готово: src/ngircd/ngircd — инструментированный бинарник"
