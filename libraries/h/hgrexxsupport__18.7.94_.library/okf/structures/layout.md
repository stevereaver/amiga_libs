---
file: layout
---
# hgrexxsupport layout

File 4996B. h0 CODE 0x478 longs (4576B @0x28,
declared==physical; last body long 7cfc4e75 is code, not
overrun). h0 RELOC32: 24->h0 + 9->h1 + 10->h2. h1 DATA
0x1b longs (108B @0x12e0: "utility.library","dos.library",
"rexxsyslib.library","%ld","0","RC","Include","MakeFlags"
+ ptr table + InitStruct `0001 0001 0000 039e`); RELOC32
2->h0 + 2->h1. h2 BSS 4 longs, END.

Resident @h0+4, 26-byte extended Node variant:
MatchTag, EndSkip->h0+4 (self), an EXTRA pointer field
@+6 ->h0+0xbe (into the functab region — likely a
"previous resident/module" link this toolchain emits),
flags 0x80 AUTOINIT @+0xa, ver 1, type 9, pri 0,
Name@+0xe ->h0+0x5c "hgrexxsupport.library",
IdString@+0x12 ->h0+0x74 "hgrexxsupport.library (18.7.94)
Copyright (c) 1994 by hartmut Goebel",
Init@+0x16 ->h0+0x1e.

InitTable @h0+0x1e: dsize 0x22, ftab->h0+0xb8 (5 entries:
-6/-12/-18 real, -24 NULL hole, -30 real), dtab->h0+0x2e,
initfn->h0+0x10ec.
