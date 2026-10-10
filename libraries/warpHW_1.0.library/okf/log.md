# warpHW.library — reconstruction log

## 2026-10-28 — reverse engineering + reconstruction

### Binary inspection
- 1392 bytes; THREE hunks: CODE(0x89 longs) + CODE(0x56
  longs) + DATA(0x25 longs).  SAS/C far-data build.
- RomTag RTF_AUTOINIT ver1, dataSize 0x22, InitTable in
  hunk0; FUNCTABLE (10 long vectors) + strings + aux
  globals in the DATA hunk.
- INITFUNCTION: stores execbase and seglist into far-data
  globals, runs a sub-init.

### Decoded
- `-30` returns a pointer to a driver descriptor/jump
  table (LAB_0025).
- `-36` returns 1.
- `-42` walks the list at `SysBase+322`, returning field
  [24] of the node whose [20]>=0x40000000 && [24]<0x80000000
  (the PPC memory/IO window).
- `-48`/`−54` write control bytes to the BlizzardPPC
  `$f6xxxx` CSPPC registers with `NOP;RTS` settle delays.
- `-60` region contains **native PowerPC instructions**
  (mflr/stwu/lis/stb/blr) — PPC code shipped as data.

### Reconstruction
- `warpHW_lib.s`: RomTag/InitTable/datatab/10-vector
  functab, INITFUNCTION storing execbase/seglist globals,
  the descriptor, and the PPC code as a `.byte` blob.
- `warpHW.c`: framework + 6 functions; register pokes as
  `*(volatile UBYTE*)0xf6xxxx = imm` (same byte values),
  list walk over `SysBase+322`.
- Built 736 bytes single-hunk — functional equivalent, not
  the original's three-hunk layout.

### Verification
- datatab byte-identical; functab 10 vectors.
- `moveb #imm,$f6xxxx` sequence matches the original's
  `MOVE.B #imm,(A0)` writes byte-for-byte.
- exec call inventory (Remove -252, FreeMem -210) matches.
