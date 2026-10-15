---
file: log
---
# Work log

- 2026-10-15: 8-hunk build; raw `.byte` emission per hunk merged
  to .text/.data, fixup.py re-splits 8 records + splices original
  RELOC32 tails. BYTE-IDENTICAL.
- machine68k oracle (generic resident-scan/InitTable path):
  InitTable@h2+0 decoded (dsz 0x192, ftab->h3, initfn->h1),
  7 vectors, open/close/expunge lifecycle + dispatch probes.
  RUNTIME-IDENTICAL. Plane AMIGALIBS-299.
