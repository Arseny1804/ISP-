# Fuzzing Report: FTP Protocol Harness (AFL++)

## 1. Objective

The goal of this experiment was to apply greybox fuzzing techniques to a simplified FTP protocol implementation using AFL++ and evaluate the effect of a custom mutator on code coverage.

---

## 2. Target System

A simplified FTP-like parser implementing the following commands:
- USER
- PASS
- LIST
- CWD
- QUIT

Implemented in C and wrapped in a fuzzing harness.

---

## 3. Tools

- AFL++ 4.33c
- LLVM Clang (coverage instrumentation)
- llvm-cov / lcov
- Python HTTP server for report viewing

---

## 4. Methodology

### 4.1 Compilation

Default build:
afl-clang-fast -g -O0 ftp_fuzz_harness.c -o ftp_fuzz_harness


Coverage build:

clang --coverage -g -O0 ftp_harness_lcov.c -o ftp_lcov


---

### 4.2 Fuzzing Setup

Two configurations were evaluated:

#### A) Default AFL++
- Standard havoc + bitflip mutators
- Input corpus: seeds2

#### B) AFL++ + Custom Mutator
- Case normalization (a→A)
- Tab normalization
- AFL custom mutator API

---

### 4.3 Execution

Both runs executed for 30 minutes:

- 12 CPU cores available
- Single instance each
- Same seed corpus

---

## 5. Results

| Metric | Default | Custom |
|------|--------|--------|
| Runtime | 30 min | 30 min |
| Corpus size | ~80 | ~83 |
| Coverage improvement | baseline | +~10–15% map density |
| Crashes | 0 | 0 |

---

## 6. Coverage Report

Coverage generated using llvm-cov and served via HTTP.

Final coverage:
- Line coverage: 100%
- Branch coverage: ~71%
- Region coverage: ~88%

---

## 7. Observations

- Custom mutator slightly improved exploration of parsing branches.
- AFL++ stability remained high (>90%)
- No crashes were found due to simplified parser design.

---

## 8. Conclusion

AFL++ successfully explored the FTP parsing logic. The custom mutator improved map density and exploration efficiency, but no crashes were discovered due to the simplicity of the target.

---

## 9. Artifacts

- coverage/lcov_html/
- runs/default_afl/
- runs/custom_afl/
- seeds/
