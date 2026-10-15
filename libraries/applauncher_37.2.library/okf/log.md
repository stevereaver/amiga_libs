---
file: log
---
# Work log

- 2026-10-15: 2-hunk SAS/C build; raw `.byte` emission
  (.text/.data), fixup.py re-splits + splices original RELOC32
  tails (7->h0, 25->h1). BYTE-IDENTICAL.
- machine68k oracle (2-hunk loader, COLDSTART entry@h0+0x20):
  MakeLibrary(21 vecs, dsz 0x22), all 21 vectors traced,
  open/close/expunge + expunge seglist return.
  RUNTIME-IDENTICAL. Plane AMIGALIBS-298.
