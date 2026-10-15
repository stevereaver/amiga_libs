# Findings & defects

- Same close-count underflow as 2.1 (cnt=65535 -> early
  remove/free).
- 2.2 is a source-level revision of 2.1 (+20B, resident shifted
  +2); tuple walk semantics unchanged.
- 0 invalid accesses.
