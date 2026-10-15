---
file: log
---
# Work log

- 2026-10-15: powerpacker 35.344 — PP cruncher lib, CODE+
  BSS, 22 abs vectors, datatab fills header. Raw .byte +
  BSS resplit fixup; BYTE-IDENTICAL. Oracle traces all 22
  vecs + open/close/expunge; RUNTIME-IDENTICAL (185449
  invalids deterministic). initfn patches exec FreeMem
  ('PPMM' hook). Plane AMIGALIBS-???.
