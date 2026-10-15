---
file: layout
---
# applauncher 37.02 layout

File 3948B. 2 hunks: h0 CODE 0x355 longs (3412B @0x24), h1 DATA
0x3a longs (0xe8 @0xe1c). Tail: RELOC32 — 7 slots ->h0,
25 slots ->h1, END.

## hunk0

| off | contents |
|-----|----------|
| 0x00 | `moveq #-1,d0 / rts` stub |
| 0x06 | Resident: flags 0x00, ver 37, type 9; name->+0x24 id->+0x38 init->+0x20 |
| 0x20 | `jmp pc@(+0x64)` into SAS/C init |
| 0x24/0x38 | name/idstr ('applauncher.library 37.02 (04.10.94)') |
| 0x64 | init: `lea $7ffe,a4` (a4-data anchor, relocated ->h1+frame), `[4]->a4@(-0x7ffa)` execbase stash, AllocMem lib node, hand-fills node fields (type 9, name ptr, ver 37, rev 2), calls MakeLibrary via helper @+0xc20 |

## hunk1 (DATA)

SAS/C small-data frame: functab (21 absolute longs) + lib pointers.
All code refs via `a4@(-disp)`; 25 relocs ->h1.
