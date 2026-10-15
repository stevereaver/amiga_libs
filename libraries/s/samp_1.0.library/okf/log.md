---
file: log
---
# Work log

- 2026-10-15: single CODE hunk; raw `.byte` emission (1990 asm lib,
  relocated jmp targets emitted as literals — fixup.py splices the
  original 37-slot RELOC32 tail). BYTE-IDENTICAL.
- machine68k oracle: direct rt_Init call (OpenLibrary dos +
  AddLibrary embedded jmp-table base 0x40090), all 18 vector slots,
  open/close/expunge lifecycle incl. RemLibrary+seglist return.
  RUNTIME-IDENTICAL. Plane AMIGALIBS-295.
