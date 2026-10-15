---
file: layout
---
# uuid 2.0.0 layout

File 4004B. 2 hunks: h0 CODE 0x3a7 longs (3740B @0x24),
h1 DATA 0xf longs (60B @0xf1c).
Tail: RELOC32 — 13 ->h0, 1 ->h1 (the InitTable functab field
@h0+0x27a), END.

## hunk0

| off | contents |
|-----|----------|
| 0x00 | `moveq #-1,d0 / rts` stub |
| 0x04 | PACKED Resident: flags 0x80, ver 2, type 9; name->+0x1e id->+0x2b init->+0x276 |
| 0x1e/0x2b | 'uuid.library' / '$VER: uuid 2.0.0 (05...)' |
| 0x276 | InitTable: dsize 0xac, functab->h1+0 (stored 0, reloc @0x27a), datatab=0, initfn->h0+0x12a |

## h1 (DATA, 60B)

functab@+0: 14 absolute longs ->h0 + `ffffffff`.
