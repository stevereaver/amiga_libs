---
type: Library
title: dpblit.library 1 (DPBlitBase)
description: >-
  dpblit.library — dual-playfield blitter driver library; 4 hunks
  (CODE + InitTable DATA + CHIP DATA blit buffer + functab CODE),
  7 vectors, opens graphics.library at init.
files:
  - source/dpblit_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# dpblit.library (DPBlitBase)

4 hunks.  Hunk0 CODE (2552B): `moveq #0,rts` stub at +0,
Resident@+4 (AUTOINIT, v1, type 9), InitTable@h1+4 (datasize
0x50, functab->h3+0 absolute, datatab=0, initfn->h0+0x20).

- hunk1 DATA 32B: pad long + InitTable + trailing {0,0xdff000,0}
  (whole hunk is later copied into lib+0x30 as private data;
  +0xdff000 becomes the chip-register base at lib+0x48)
- hunk2 DATA|CHIP 512B of zeros — chip-RAM blit pattern buffer,
  referenced via `pea`/`clr.w`/`lea` absolute slots in -30
- hunk3 CODE 60B: 7-entry functab + 'dpblit.library' +
  'DPBlitBase' (+ one odd trailing 'l' byte)

## Build

`dpblit_h0.s` verbatim: head resident/stub and the h0+0x1a0
mask-table/strings region emitted raw; all four hunk bodies go
into one .text section.  `fixup.py` asserts the concatenated
bodies match and rewrites the file into the original 4-hunk
layout (CHIP flag on hunk2 tag/size preserved) splicing the
original RELOC32 tails.  Byte-identical
(md5 c3d70837f12093556ce3f98b54f2fbf3).

## Runtime

`work/oracle.py`: init, all 7 vectors, open x2, close x2
(deferred + real expunge).  Identical original vs rebuild.
