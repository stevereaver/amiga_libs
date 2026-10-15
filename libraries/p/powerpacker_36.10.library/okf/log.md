---
file: log
---
# Work log

- 2026-10-15: powerpacker 36.10 — PP cruncher lib, CODE+
  BSS, 23 abs vectors, datatab fills header. Raw .byte +
  fixup tail splice; BYTE-IDENTICAL. Oracle traces all 23
  vecs + open/close/expunge; RUNTIME-IDENTICAL (185452
  invalids deterministic). initfn patches exec FreeMem
  ('PPMM' hook); dep bases stored into name strings.
  Plane AMIGALIBS-???.
