---
file: layout
---
# mathieeesingbas 36.11 layout

File 3852B. Header: 3 hunks — h0 CODE 0x390 longs (3648B @0x28),
h1 CODE 0-long, h2 DATA 0-long (linker-emission artifacts).
Tail: 9 RELOC32 groups ->h0, HUNK_ENDs.

## hunk0

| off | contents |
|-----|----------|
| 0x00 | `movel #-1,d0 / rts` stub (returns -1) |
| 0x08 | Resident: flags 0x01 (COLDSTART, **not** AUTOINIT), ver 36, type 9; name->0x22 id->0x3a init->0x76 |
| 0x22/0x3a | name/idstr |
| 0x62 | `MathIEEE.resource` string |
| 0x76 | init code: `movel a0,$1f2` stores seglist in a low-mem slot, probes attn bit4 + MathIEEE.resource, `MakeLibrary(-84)` with dsize 0x3c, datatab@0x12a, initfn=0; then `AddLibrary(-396)` + fills lib fields manually |
| 0x1f8 | functab A (default, 17 entries) |
| 0x21c | functab B (16 entries — used when no resource/attn) |
| 0xe1c | functab C (16 entries — resource-present variant) |

All three functabs are **word-offset** tables (0xffff bookends,
offsets relative to table base; several entries negative — point
back into early code).
