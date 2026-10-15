---
file: log
---
# Work log

- 2026-10-15: powerpacker 020+ 37.0 (1996) — PP cruncher,
  single CODE hunk, alloc 0x5ad > body 0x5a3 (40B globals
  tail), 23 word-offset vectors, datatab fills header
  (lib 36.10 vs idstring 37.0 quirk), initfn patches exec
  FreeMem w/ 'PPMM' hook. Raw .byte + 1-hunk tail-splice
  fixup; BYTE-IDENTICAL (md5 fd547a1b8cee58bf211dca493519cff3).
  Oracle traces all 23 vecs + open/close/expunge;
  RUNTIME-IDENTICAL (9348816 invalids deterministic).
  Plane AMIGALIBS-???.
