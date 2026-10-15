---
file: layout
---
# xpkIMPL 1.0.79 layout

File 4048B. Single hunk0 CODE 0x3bb longs (3820B @0x20).
Tail: RELOC32 — two ->h0 groups (39 + 4 entries; the group
boundary splits the functab at +0xa4/0xa8), END.

## hunk0

| off | contents |
|-----|----------|
| 0x00 | `moveq #-1,d0 / rts` stub |
| 0x04 | Resident: flags 0x80 AUTOINIT, ver 1; name->+0x1e id->+0x35 init->+0x5c |
| 0x1e | 'xpkIMPL.library' |
| 0x35 | 'xpkIMPL 1.0.79 (02-Nov-92 01:24:18)\r\n' |
| 0x5c | InitTable: dsize 0x28, ftab->+0x6c, dtab->+0xbc, initfn->+0xe8 |
| 0x6c | functab: 19 absolute longs + `ffffffff` |
| 0xbc | InitStruct byte-cmd datatab (e0/09/c0/06 commands) |
| 0xe8 | initfn; code to 0xeec |
