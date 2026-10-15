---
file: layout
---
# f1gp 36.10 layout

File 4180B. 2 hunks:
- h0 CODE 0x3b3 longs (3788B @0x24), tail RELOC32: 22 ->h0 +
  23 ->h1 (descending order in second group).
- h1 DATA: size-table alloc 0x76 longs (472B) but hunk-tag size
  0x22 longs (136B @0xfc8) — the remaining 0x54 longs are
  reserved-but-unfiled space (same shape as rexxidentify's
  alloc>body quirk). Body contains embedded PPC opcodes
  (fff8ff4c = bcl- patterns etc.) + a4-model data.

## hunk0

| off | contents |
|-----|----------|
| 0x00 | `moveq #-1,d0 / rts` stub |
| 0x04 | Resident: flags 0x00, ver 36, type 9; name->+0x1e id->+0x2b init->+0x6c |
| 0x1e | 'f1gp.library' |
| 0x2b | '$VER: f1gp 36.10 ...' |
| 0x6c | COLDSTART entry: regs, `lea 0x7ffe,a4` (reloc->h1 anchor),
       | zero a4@(-32766)..(0x54+1 longs), probe @0xe2c/@0xe34,
       | on success jmp +0x3e8 |
| 0x3b8 | functab: 11 absolute longs + `ffffffff` |
| 0x3e8 | real init: exec -552 OpenResource, MakeLibrary(dsize
       | 0x3e, ftab@+0x3b8, no datatab, no initfn),
       | NewList x2 (-558), AddLibrary (-396) |
