---
file: layout
---
# mcpsupport2 7.1 layout

File 4196B. Single hunk0 CODE 0x3d7 longs (3932B @0x20).
Tail: RELOC32 — one 53-entry ->h0 group, END.

## hunk0

| off | contents |
|-----|----------|
| 0x00 | `moveq #-1,d0 / rts` stub |
| 0x04 | Resident: flags 0x80 AUTOINIT, ver 7; name->+0x1e id->+0x32 init->+0x78 |
| 0x1e | 'mcpsupport2.library' |
| 0x32 | '$VER: mcpsupport2 7.1 ...' |
| 0x78 | InitTable: dsize 0x22, ftab->+0x88, dtab->+0xd4, initfn->+0xf4 |
| 0x88 | functab: 19 absolute longs (4 zero holes) + `ffffffff` @0xd0 |
| 0xd4 | InitStruct datatab (a0/80/90 commands) |
| 0xf4 | initfn: AllocMem, OpenLibrary dos v37 + utility v36 |
