---
file: defects
---
# Findings

- InitTable lives in the DATA hunk; rt_Init relocates
  ->h1 (h0's ->h1 group covers resident fields + code
  refs into h1).
- Open counter opencnt semantics normal; expunge
  deferred via flags bit3.
- No invalid accesses.
