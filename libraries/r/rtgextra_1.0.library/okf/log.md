---
file: log
---
# Work log

- 2026-10-15: 3-hunk AUTOINIT rtgextra; raw `.byte` emission
  for all hunks, resplit fixup preserves all reloc tails.
  BYTE-IDENTICAL.
- machine68k oracle (generic AUTOINIT harness): InitTable@h2+4
  decoded incl. ->h1 functab reloc, 15 vectors, lifecycle.
  RUNTIME-IDENTICAL. Plane AMIGALIBS-318.
