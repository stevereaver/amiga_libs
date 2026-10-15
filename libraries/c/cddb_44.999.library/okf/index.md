# cddb.library 44.999 — OKF index

CDDB/freedb client library. Compiled C (subqw/lea frames, stack args),
AUTOINIT, two hunks: h0 CODE 0x9b8 B (622 longs) + h1 DATA 0x68 B
(26 longs). File 2816 B, MD5 `35f2dd379949c90b8e7f65d0205c8993`.

Reconstruction: pure 68k asm transcription (`source/cddb_h0.s` +
`source/cddb_h1.s` + `Makefile` + `fixup.py`), byte-identical to the
original. machine68k oracle (`work/oracle.py`, fakes exec/utility/
freedb) shows identical traces for init ctx-copy, Open/Close/Expunge,
error-string lookup, discid compute, and the -30 query sequence.

The library wraps freedb.library: init opens utility.library v36 +
freedb.library v2 into a private ctx at lib+48 which is initialised
by copying the first 96 bytes of the DATA hunk (an overlapping
`moveb (a1)+,(a6)+` loop hidden inside a `cmpiw` opcode) and then
self-relativizing one pointer (ctx+0x5c -> &ctx[0x4c]).

See `functions/vectors.md`, `structures/layout.md`,
`findings/quirks.md`, `log.md`.
