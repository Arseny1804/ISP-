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
