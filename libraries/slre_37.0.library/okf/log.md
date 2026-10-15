---
file: log
---
# Work log

- 2026-10-15: slre.library 37.0 — 4-hunk regex lib
  (CODE+DATA+DATA+CODE, per-hunk RELOC32/END, cross-hunk
  RomTag). Raw .byte sections (.text h0+h3, .data h1+h2)
  + order-slicing fixup; BYTE-IDENTICAL. 4-base oracle:
  resident parse, initfn (header build + h1->libbase+0x3c
  copy), all 5 vectors, open x2/close/expunge, invalid
  counter — orig vs rebuilt logs DIFF CLEAN.
