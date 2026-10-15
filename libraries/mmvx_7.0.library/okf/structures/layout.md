---
file: layout
---
# mmvx 7.0 layout

File 4304B. 2 hunks: h0 CODE 0x3c2 longs (3848B @0x24),
h1 BSS 0x47 longs (284B, no file body).
Tail: RELOC32 — 81 ->h0, 14 ->h1(BSS-addr refs!), END.

## hunk0

| off | contents |
|-----|----------|
| 0x00 | `moveq #0,d0 / rts` stub |
| 0x04 | PACKED Resident: flags 0x00, ver 7, type 9; name->+0x1e id->+0x32 init->+0x52 |
| 0x52 | init: `moveal 4,a6`, MakeLibrary(a0=functab@+0x17a, a1=0, a2=initfn@+0x7e, d0=0x2a, d1=seglist), AddLibrary |
| 0x7e | initfn: fills lib node fields (type 9, name->+0x1e, ver 7, rev 0, id->+0x32, seglist->+34), OpenLibrary(-552) 'dos.library' -> h0+0xe84 slot |
| 0x17a | functab: 41 absolute longs ->h0 |
| 0x1e/0x32 | 'mmvx.library' / 'mmvx.library 7.0 (22.9.2021)\r\n' |
| 0xe50/0xe5d/0xe6b/0xe77 | 'mmv8.library' / 'mmv88.library' / 'dos.library' / 'audio.device' |
| 0xe84/0xe88/0xe8c | cached bases: dos / mmv8 / mmv88 |
| 0xe9c | 'SDAT' marker + zero pad to 0xf08 |

## h1 (BSS 284B)

Runtime state; code refs via 14 relocs ->h1.
