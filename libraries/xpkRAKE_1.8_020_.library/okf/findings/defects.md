# Findings & defects

- 020-specific codegen of the same source (functions shifted
  ~+0xe, file +456B vs 000).
- -36 allocates 128KB scratch; downward R/W probing near
  0xffffffff during compress.
- Close underflows open count (65534).
