---
file: log
---
# Work log

- 2026-10-15: verbatim asm transcription of the single CODE hunk;
  fixup.py splices the original header + RELOC32 tail.
  BYTE-IDENTICAL.
- machine68k oracle (non-AUTOINIT path adapted from
  mathieeesingbas_36.11): init trace (OpenResource fpsp.resource,
  MakeLibrary 16 vecs, AddLibrary, seglist->$17e), all 16 vectors,
  expunge returning the stashed seglist. RUNTIME-IDENTICAL.
  Plane AMIGALIBS-294.
