---
file: log
---
# Work log

- 2026-10-15: mathtrans 31.2 WB1.1 — 19-hunk per-function
  build. Raw .byte concatenation of all bodies into .text;
  resplit fixup restores the 19-entry header, per-hunk tags
  and RELOC32 tails. BYTE-IDENTICAL.
- machine68k oracle (mathtrans_1.3 generic AUTOINIT harness):
  InitTable@h0+0x4c, 21 vectors, open/close/expunge.
  RUNTIME-IDENTICAL incl. deterministic invalid reads.
  Plane AMIGALIBS-322.
