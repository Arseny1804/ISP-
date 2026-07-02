Fuzzing Report: FTP Protocol Harness (AFL++)
1. Objective

This project applies greybox fuzzing techniques using AFL++ to a simplified stateful FTP-like protocol implementation.
The goal is to evaluate the effect of a custom mutator on coverage and exploration efficiency.

2. Target System

A simplified FTP parser supporting:

USER
PASS
LIST
CWD
QUIT

The parser is stateful and processes sequential command input streams.

3. Tools
AFL++ 4.33c
Clang/LLVM (coverage instrumentation)
llvm-cov / lcov
Python HTTP server (for HTML coverage report)
4. Methodology
4.1 Compilation

Fuzzing build:

afl-clang-fast -g -O0 ftp_fuzz_harness.c -o ftp_fuzz_harness

Coverage build:

clang --coverage -g -O0 ftp_harness_lcov.c -o ftp_lcov
4.2 Fuzzing configurations

Two configurations were evaluated:

A) Default AFL++
Standard mutation strategies (bitflip, havoc, splice)
Input corpus: seeds2/
B) AFL++ + Custom Mutator

Custom mutator performs:

ASCII lowercase → uppercase normalization
Tab → space normalization
Protocol-aware preprocessing for FTP commands
4.3 Execution

Both runs executed for approximately 30 minutes:

12 CPU cores available
Same seed corpus
Independent output directories
5. Results
Metric	Default AFL++	Custom Mutator
Runtime	30 min	30 min
Corpus size	~80	~83
Map density	~33–52%	~48–69%
Crashes	0	0
New edges	5–6	6
6. Coverage Report

Generated using llvm-cov and served via HTTP.

Final metrics:

Line coverage: 100%
Branch coverage: ~71%
Region coverage: ~88%
7. Observations
Custom mutator improved exploration of protocol parsing branches.
AFL++ stability remained high (>90%).
No crashes were discovered due to simplified target implementation.
Coverage gain is modest but consistent.
8. Conclusion

AFL++ successfully explored the FTP-like protocol parser.

The custom mutator provided:

slightly better branch exploration
higher map density
improved corpus diversity

However, due to the simplicity of the target, no security-relevant crashes were found.

9. Artifacts
runs/default/ – default AFL++ execution
runs/custom/ – custom mutator execution
coverage/lcov_html/ – HTML coverage report
seeds/ – initial corpus
mutator/ftp_mutator.c – custom mutator implementation
