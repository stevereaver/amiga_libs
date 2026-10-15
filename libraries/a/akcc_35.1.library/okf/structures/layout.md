# Layout

- Header: 6 hunk table sizes (165,16,1,876,26,143 longs).
- h0 CODE recsize 0xa5 (body 0x294B @file 0x34): stub+resident+
  strings+functab+InitTable+glue.
- h1 BSS: table declares 16 longs but record size is 0 (no body;
  alloc-vs-record quirk).
- h2 CODE 1 long: `16c0 4e75` (moveq?,rts stub).
- h3 CODE 0x36c longs (0xdb0B) @file 0x43c: main implementation.
- h4 DATA 0x1a longs @file 0x1308: globals (incl. dep bases).
- h5 CODE 0x8f longs @file 0x137c: tail code.
- Relocs: h0 20->h0,15->h1,40->h3; h3 42->h1,1->h2,6->h4,9->h5.
- InitData @h0+0x136 fills lib header (pri0,type9,flags6,ver35,rev1,
  name,id).
