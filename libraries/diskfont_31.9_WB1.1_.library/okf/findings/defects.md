---
file: defects
---
# Findings

- rt_Flags=0x00 plain resident: rt_Init is CODE that performs the
  whole bootstrap (MakeLibrary + AddLibrary) — WB1.x predates the
  AUTOINIT InitTable convention exec handles.
- functab's last entry is a relocated **0 longword** (->h1+0) —
  the assembler emitted a reloc slot for a literal-0 pointer;
  exec treats it as a valid vector, preserved verbatim.
- Two zero-length hunks (h8 DATA, h9 CODE) — linker artifacts kept
  in the rebuild.
- 1.6M->6k invalid accesses difference vs first oracle run came from
  a strided functab decode in the harness, not the lib.
