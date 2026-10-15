---
file: defects
---
# Findings

- SAS/C a4 small-data model: code accesses data via `a4@(-disp)`;
  `lea $7ffe,a4` stores an in-frame offset relocated ->h1 (a4 lands
  h1+0x7ffe so a4-0x7ffa = h1+4).
- Resident flags=0: rt_Init is a `jmp` into C bootstrap code; no
  AUTOINIT InitTable.
- expunge returns the stashed seglist; close-underflow path runs
  RemLibrary + CloseLibrary + 3 FreeMem calls.
