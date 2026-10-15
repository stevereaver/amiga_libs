---
file: layout
---
# rexxhost 36.14 layout

File 3820B. Header: 3 hunks — h0 CODE 0x340 longs (3360B @0x28),
h1 DATA 0x1e longs (120B @0xde8), h2 BSS 0x1 long (4B, no body).

Relocs: h0 has ->h1 group {0x12,0x16,0x1a,0x4e} + 19 ->h0 slots;
h1 has ->h1 {0x68} + 24 ->h0 slots (the whole functab + name/idstr
pointers + initfn field).

## h0 (CODE)

| off | contents |
|-----|----------|
| 0x00 | `moveq #-1,d0 / rts` stub |
| 0x04 | Resident AUTOINIT v36 pri 0; name->h1+0, id->h1+4, init->h1+0x64 — **all resident pointer fields are relocated into the DATA hunk** |
| 0x1e | initfn entry (reached via InitTable initfn -> h0+0x1e) |
| 0x52/0x66 | name/idstr strings inline among code |
| 0x156/0x166 | dos.library / rexxsyslib.library dep strings |

## h1 (DATA, 120B)

| off | contents |
|-----|----------|
| 0x00 | ->h0+0x54 `rexxhost.library` name |
| 0x04 | ->h0+0x66 idstr `rexxhost.library 36.14 (09 Sep 1990)` |
| 0x08 | 0 separator |
| 0x0c | functab: 21 absolute longs ->h0 (0x17a..0xa4c), ffffffff @0x60 |
| 0x64 | InitTable: dsz=0x26, functab->h1+0xc, datatab=0, initfn->h0+0x1e |
| 0x74 | trailing value 0xe |

## h2

4-byte BSS (single longword global).
