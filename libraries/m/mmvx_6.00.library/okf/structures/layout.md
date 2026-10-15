---
file: layout
---
# mmvx 6.00 layout

File 3984B. 2 hunks: h0 CODE 0x37d longs (3572B @0x24),
h1 BSS 0x11c longs (1136B, no file body).
Tail: RELOC32 — 66 ->h0, 14 ->h1(BSS-addr refs!), END.

## hunk0

| off | contents |
|-----|----------|
| 0x00 | `moveq #0,d0 / rts` stub |
| 0x04 | PACKED Resident: flags 0x00, ver 6, type 9; name->+0x1e id->+0x32 init->+0x80 |
| 0x80 | init: `moveal 4,a6`, MakeLibrary(a0=functab@+0x1a8, a1=0, a2=initfn@+0xac, d0=0x2a, d1=seglist), AddLibrary |
| 0xac | initfn: fills lib node fields (type 9, name->+0x1e, ver 6, rev 0, id->+0x32), OpenResource(-552) -> h0+0xd70 slot |
| 0x1a8 | functab: 41 absolute longs ->h0 |
| 0x1e/0x32 | 'mmvx.library' / 'mmvx.library 6.00 (21 Feb 1994)\r\n' |

## h1 (BSS 1136B)

Runtime state; code refs via 14 relocs ->h1.
