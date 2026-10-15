---
file: log
---
# Work log

- 2026-10-15: verbatim asm transcription of hunk0 + BSS tail;
  fixup.py re-splits hunks and splices the original DREL16 tail.
  BYTE-IDENTICAL.
- machine68k oracle (adapted w/ DREL16 tail support): resident scan,
  InitTable@h0+0x100 (dsz 0x2c), init opens 4 dep libs (identify
  v41), all 5 vectors, close-underflow/deferred-expunge.
  RUNTIME-IDENTICAL. Plane AMIGALIBS-293.
