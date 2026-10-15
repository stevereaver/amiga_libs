---
file: log
---
# Work log

- 2026-10-15: ire 3.17 — 4-hunk AUTOINIT, DREL16 h0
  tail, resident+InitTable in h0, 9 abs vectors. Raw
  .byte x3 + .bss hunk; resplit fixup w/ DREL16 walk;
  BYTE-IDENTICAL. Oracle traces vecs; RUNTIME-IDENTICAL.
  Plane AMIGALIBS-367.
