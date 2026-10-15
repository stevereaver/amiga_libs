---
file: log
---
# Work log

- 2026-10-15: pccard 1.1 — flat single-hunk AUTOINIT,
  RELOC32 49-slot self-relocs, resident+InitTable+InitData
  packed mid-hunk. Raw .byte + flat fixup (orig tail
  splice); BYTE-IDENTICAL. Oracle: exec+utility stubs,
  real CloneTagItems/NextTagItem/TagInArray, three fake
  CIS tuples drive -30, -36 frees clone recursively;
  RUNTIME-IDENTICAL, 0 invalids. Plane AMIGALIBS.
