---
file: layout
---
# realtime 40.2 layout

File 3980B. 2 hunks: h0 CODE 0x3be longs (3832B @0x24),
h1 DATA 8 longs (32B @0xf68: 'ciaa.resource','ciab.resource').
Tail: RELOC32 — 7 ->h0 (incl. resident fields), 3 ->h1.

## hunk0

| off | contents |
|-----|----------|
| 0x00 | `moveq #0,d0 / rts` stub |
| 0x04 | PACKED Resident: flags 0x80, ver 40, type 9; name->+0x1e id->+0x2f init->+0x4a |
| 0x1e/0x2f | name/idstr |
| 0x4a | InitTable: dsize 0xf2, functab->h0+0x5a, datatab=0, initfn->h0+0x84 |
| 0x5a | word-offset functab: `ffff` + 19 words + `ffff` |
