---
file: log
---
# Work log

- 2026-10-15: CODE + BSS hunks; raw `.byte` emission, fixup.py
  splices original tail (which itself contains the BSS hunk
  record). BYTE-IDENTICAL.
- machine68k oracle (COLDSTART@h0+0x80): MakeLibrary(41 vecs,
  dsz 0x2a), initfn resource probe, all vectors, expunge seglist.
  RUNTIME-IDENTICAL. Plane AMIGALIBS-304.
