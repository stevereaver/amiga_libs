---
file: layout
---
# powerpacker 020+ 37.0 layout

File 5864B. HUNK_HEADER 1 hunk, alloc 0x5ad longs. h0 CODE
0x3e9 body 0x5a3 longs (5772B @file 0x20) — alloc exceeds
body by 10 longs: hunk+0x168c..0x16b3 is the runtime globals
pad (12B descriptor @0x168c, saved old FreeMem vec @0x16a0,
libbase+dep-base store @0x16a4/8/c/0). RELOC32 @0x16ac:
10 slots ->h0 @0x06/0a/12/16/1a (resident fields), 0x28/0x42
(datatab literal pointers), 0x50/54/58 (InitTable). HUNK_END.

Resident @h0+4, standard 22B: endskip 0x4a, flags 0x80
AUTOINIT, ver 37, type 9, pri 0, name->h0+0x5c
"powerpacker.library", id->h0+0x70 "pplib 020+ 37.0
(06.11.96)\r\n", init->h0+0x4c.

InitTable @h0+0x4c: dsize 0x28, ftab->h0+0x1d4 (0xffff
marker + 23 signed word offsets rel. to table base, 0xffff
term), dtab->h0+0x1e, initfn->h0+0xbc.

datatab (word-aligned InitData stream @0x1e..0x45) fills:
ln_Type=9, ln_Name->0x5c, lib_Flags=6, lib_Version=36,
lib_Revision=10, lib_IdString->0x70.

Dep strings inline @h0+0x8d "dos.library", +0x99
"intuition.library", +0xab "graphics.library". Error/
requester strings + reqtools.library text @0x15af..0x1688;
codec markers 'PP20' @0x844/@0xa0a, 'PPMM' @0x93a, '.pp'
@0x165a.
