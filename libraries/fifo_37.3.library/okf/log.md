---
file: log
---
# Work log

- 2026-10-15: 2-hunk build; raw `.byte` emission, fixup.py
  re-splits + splices RELOC32 tails (7->h0, 10->h1).
  BYTE-IDENTICAL.
- machine68k oracle (COLDSTART entry@h0+0x50): MakeLibrary via
  h1 functab (10 vecs), all vectors, open/close/expunge.
  RUNTIME-IDENTICAL. Plane AMIGALIBS-302.
