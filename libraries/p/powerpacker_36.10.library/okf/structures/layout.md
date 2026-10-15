---
file: layout
---
# powerpacker 36.10 layout

File 6128B. h0 CODE 0x5b9 longs (5860B @0x24), RELOC32
43 slots ->h0 + 5 slots ->h1. h1 BSS 0x3eb 4 longs (16B
globals; header table reserves 4 and — unlike 35.344 whose
BSS size field is 0 — this hunk's own size field in the
file is also 4). Resident @h0+0x30, standard 22B: flags
0x80 AUTOINIT, ver 36, name->h0+4 "powerpacker.library",
id->h0+0x18 "pplib 36.10 (28.9.93)", init->h0+0x78.

InitTable @h0+0x78: dsize 0x28, ftab->h0+0x1ba (23 abs
longs, -1 term @0x216), dtab->h0+0x4a, initfn->h0+0xb8.
Dep strings dos/intuition/graphics.library inline @0x88-0xb6
before initfn. datatab fills lib header (ver 36 @+0x14,
rev 0xa=10 @+0x16).

Other strings: PP20 magic refs @0x884/0xb1c, 'PPMM'
@0xa5a/0xcbc (FreeMem hook alloc-guard tag), reqtools nag
"You need reqtools.library" @0x973, error-ptr table @0x9a4
(8 ptrs) -> msgs @0x9c4-0xa53 ("unable to open file",
"error reading file", "out of memory", "encrypted file",
"incorrect password", "unknown PP data header",
"empty file", "unknown error occured"), requester text
"Incorrect!"/"Please verify"/"Error! Restart" @0xd76-0xd9e.
