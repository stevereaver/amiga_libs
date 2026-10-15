---
file: log
---
# Work log

- 2026-10-15: virtualmem 1.2 — 2-hunk AUTOINIT vmem lib,
  extended 26B resident, 17 abs vectors in DATA hunk,
  init deps dos37/multiuser39. Raw .byte + 2-hunk resplit
  fixup; BYTE-IDENTICAL. Oracle traces all 17 vectors with
  sem/alloc/list ops; RUNTIME-IDENTICAL. Plane AMIGALIBS-355.
