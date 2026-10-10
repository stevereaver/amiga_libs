---
type: Algorithm
title: zlib 1.1.4 core
description: Stock zlib 1.1.4 algorithms; gzio layer replaced with dos.library I/O.
---

# zlib 1.1.4 core

Stock algorithms from zlib 1.1.4: deflate (LZ77+Huffman), inflate via
infblock/infcodes/inffast/inftrees/infutil, trees, adler32, crc32, zutil —
confirmed by "deflate 1.1.4" / "inflate 1.1.4" copyright strings and matching
error strings ("invalid bit length repeat", "oversubscribed distance tree",
...). Two full builds exist in the binary (m68k hunk0 + PPC hunk1).

Amiga-specific changes (all in `gzio.c`/`zutil.h`):

- file I/O: `Open/FRead/FWrite/Seek/Close` (dos.library), `file` is BPTR
- alloc: `AllocVec(...,MEMF_PUBLIC|MEMF_CLEAR)`; PPC: `AllocVecPPC(...,4)`
- `gzdopen` treats its arg as a BPTR, not a unix fd
- memory helpers `GZ_CompressMem`/`GZ_DecompressMem` are the only
  deflate/inflate entry points exposed — no raw z_stream API is exported;
  `compress.c`/`uncompr.c` ship in the archive but are not reachable via any LVO
