# AFL++ Fuzzing of FTP Protocol Parser

## 1. Project Overview

This project demonstrates grey-box fuzzing of a simplified FTP protocol implementation using AFL++.

The goal is to compare:
- Default AFL++ mutation strategy
- Custom protocol-aware mutator
- Code coverage analysis (llvm-cov / LCOV)
- Fuzzing efficiency over a fixed time budget

---

## 2. Target Application

A simplified FTP-like protocol parser implemented in C supporting:

- USER
- PASS
- LIST
- CWD
- QUIT

The parser is intentionally simplified for fuzzing and coverage analysis.

---

## 3. Tools Used

- AFL++ 4.33c
- clang / afl-clang-fast
- llvm-cov / lcov
- Python HTTP server (for coverage viewing)

---

## 4. Build Instructions

### AFL++ Instrumented Build

```bash
afl-clang-fast -g -O0 ftp_fuzz_harness.c -o ftp_fuzz_harness
```

### Coverage Build

```bash
clang --coverage -g -O0 ftp_harness_lcov.c -o ftp_lcov
```

---

## 5. Fuzzing Setup

### Default AFL++

```bash
afl-fuzz -i seeds2 -o out_default -- ./ftp_fuzz_harness
```

### Custom Mutator AFL++

```bash
gcc -shared -fPIC -O2 ftp_mutator.c -o ftp_mutator.so

AFL_CUSTOM_MUTATOR_LIBRARY=./ftp_mutator.so \
afl-fuzz -i seeds2 -o out_custom -- ./ftp_fuzz_harness
```

---

## 6. Results

| Metric           | Default AFL++ | Custom Mutator |
|------------------|--------------|----------------|
| Runtime          | 30 min       | 30 min         |
| Corpus size      | ~80          | ~83            |
| Crashes          | 0            | 0              |
| Branch coverage  | ~71%         | ~71–75%        |
| Map density      | baseline     | slightly higher |

---

## 7. Coverage Report

- Line coverage: 100%
- Branch coverage: ~71%
- Region coverage: ~88%

### Run coverage server

```bash
python3 -m http.server 8000
```

Open in browser:

```
http://localhost:8000/lcov_html/
```

---

## 8. Conclusion

AFL++ successfully fuzzed a simplified FTP parser.

Custom mutator slightly improved exploration but did not significantly change branch coverage.

The experiment demonstrates:
- AFL++ workflow
- Greybox fuzzing
- Custom mutator integration
- Coverage-guided fuzzing
