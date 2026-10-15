---
file: log
---
# Work log

- 2026-10-15: 13-hunk WB1.2 build; raw `.byte` emission of all
  bodies (merged .text/.data), fixup.py re-splits to the original
  hunk records + splices original RELOC32 tails. BYTE-IDENTICAL.
- machine68k oracle (13-hunk loader, COLDSTART init@h0+0x50):
  MakeLibrary(dsz 0x38, 6 vecs incl. relocated-0 entry), AddLibrary,
  initfn, all vectors, expunge returning seglist.
  RUNTIME-IDENTICAL. Plane AMIGALIBS-297.
