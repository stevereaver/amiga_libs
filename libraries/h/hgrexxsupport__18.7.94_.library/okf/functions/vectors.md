---
file: vectors
---
# Vectors (abs-long functab @h0+0xb8)

-6 Open +0x1162 | -12 Close +0x1182 | -18 Expunge +0x1182?? 
(entries: 0x113c, 0x1162, 0x1182, 0x0000 hole, 0x0504).
Targets: -6->h0+0x113c, -12->h0+0x1162, -18->h0+0x1182,
-24 NULL, -30->h0+0x504. Under oracle: open bumps cnt,
-24->0x14, -30->1.

initfn @h0+0x10ec: AllocMem(364,MEMF_PUBLIC), OpenLibrary
utility v37 / dos v33 / rexxsyslib v33 (strings in h1).
