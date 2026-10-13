# support.library 1.2

- **Binary**: `binary/support_1.2.library` (2200 bytes)
- **Version string**: `support.library 1.2 (11 Januar 96)`
- **Author**: Thomas Wenzel / T&T (banner text `© 1996 by T&T`)
- **CPU**: plain 68000 code (DBF loops, no 020+ instructions)
- **Structure**: single CODE hunk (2032 bytes).  Packed `struct
  Resident` at code+0x66 (unaligned long fields), RTF_AUTOINIT;
  InitTable at +0xb4 {dsize=42, functab@+0xc4, datatab@+0x110,
  initfn@+0x13c}; shared scratch block at code+0x700; dead
  banner-print routine at code+0.
- **Role**: image/RGB helper library operating on *row-interleaved*
  RGB buffers — each pixel row is stored as three consecutive byte
  rows (R,G,B), so one "row triple" spans 3*rowlen bytes.  Provides
  resolution snapping, channel isolation/clears, invert, grayscale,
  scanline, dither, triple swap, mirror, R<->B swap, a 10x10 block
  mosaic (via caller-supplied mathffp.library base in a4), and a
  channel-transpose/scatter copy.

## Vectors (18, LVOs -6..-108)

| LVO | Name | Args | Result |
|---:|---|---|---|
| -6 | Open | a6=lib | lib; OpenCnt(+32).w++, clears flag bit3 @+14 |
| -12 | Close | a6=lib | OpenCnt--; at 0 + flag3 -> expunge, ret seglist |
| -18 | Expunge | a6=lib | flag3 if open else remove/free, ret seglist |
| -24 | stub | — | 0 (real `moveq #0,d0;rts`, not a NULL entry) |
| -30 | SnapSize | d0 w, d1 h, d2 mode, d3 flag, a0/a1 out, a2 wh2, a3 ctr | w residue |
| -36 | Keep0 | a0 buf, d0 rowlen, d1 total | clear triple rows 1,2 |
| -42 | Keep1 | same | clear rows 0,2 |
| -48 | Keep2 | same | clear rows 0,1 |
| -54 | Clear2 | same | clear row 2 only |
| -60 | Invert | a0, d0 n | b=255-b over n bytes |
| -66 | Gray | a0, d0 triples, d1 cols | per-column mean of 3 rows |
| -72 | Scanline | a0, d0 rowlen, d1 total | clear every other triple |
| -78 | Dither | a0, d0 n | clear every other byte |
| -84 | Swap3 | a0, d0 n | end-to-end triple swap w/ byte reverse |
| -90 | Mirror | a0, d0 width, d1 pixel-rows | reverse each byte row |
| -96 | SwapRB | a0, d0 rowlen, d2 total | swap triple rows 0<->2 |
| -102 | Mosaic | a0, d0 w, d1 h, a4=mathffp | 10x10 block average in place |
| -108 | Transpose | a0 src, a1 dst, d0 w, d1 h | scatter to channel planes |

## Rebuild

`source/` contains `support.c` + `support_lib.s` + `support_end.s` +
`Makefile` (m68k-amigaos-gcc -m68020, nostdlib).  Behaviour verified
instruction-for-instruction against the original under machine68k:
66/66 oracle cases identical — init, lifecycle (incl. deferred and
double expunge), all snap/counter paths, every buffer transform, the
mathffp call sequence, d0 residues, and the dead banner routine
(`work/oracle.py` + `work/exercise.py`, not committed).
