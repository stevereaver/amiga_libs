---
type: Library
title: bitmap.library 1.4 (10.5.95, Stefano Reksten)
description: >-
  Reksten bitmap.library 1.4 — register-arg planar bitmap helper:
  BitMap alloc/free wrappers (manual planes <V39 / AllocBitMap >=V39),
  BltBitMap-based scaler, chunky<->planar pixel I/O, row-offset table.
timestamp: 2026-10-15T04:30:00Z
---

# bitmap.library 1.4 — OKF index

Binary: `binary/bitmap_1.4.library` — 3216 bytes; CODE hunk 0x2cd
longs (2868B) + DATA hunk 0xb longs (44B, the AUTOINIT init payload);
CODE relocs: 48 same-hunk + 3 ->hunk1; DATA relocs: 2 ->hunk0.
md5 `12107804a3928ea2b95e31f7720c94f1`, sha256
`7d031be17c52a6bb68a81502241303444a3faba934c265971d8dcb09691d9546`.

idstring `bitmap 1.4 (10.5.95) Copyright (C) 1994-1995 by
Stefano Reksten` @code+0x41.  AUTOINIT RomTag @+0x34, InitTable
@+0x92 dsize=0x9a, **longword-pointer** functab @+0x9c (12 vectors,
-1 terminator), datatab @+0xf8, initfn @+0x122.

## Status

DONE — BYTE-IDENTICAL verbatim-asm reconstruction
(`source/bitmap_h0.s`, md5 `12107804a3...`) via `make`
(gas -> link -> `fixup.py` splices original 2-hunk RELOC32
trailers).  Runtime identical under machine68k (`work/oracle.py`,
orig.log == rebuild.log): initfn data-hunk copy, open x2, all 12
vectors incl. gfx-v20 manual-plane path and gfx-v39 AllocBitMap
path, putpixel->getpixel round-trip, scaler 3 flag paths,
deferred+real expunge.

## Layout

- +0x00 entry stub `moveq #0,d0/rts` (also the -24 null vector)
- +0x22 RomTag (RTF_AUTOINIT, ver 1 rev 4), name "bitmap.library"
  @+0x33, idstr @+0x41
- +0x92 InitTable -> dataSize 0x9a, functab, datatab, initfn
- +0x9c functab: LONGWORD pointers (no 0xffff marker), -1 end
- +0x122 initfn: copies 40 bytes of hunk1 into lib+0x30 (private),
  then OpenLibrary("graphics.library") -> lib+0x5c; returns 0 on
  failure (opens fail if gfx missing)
- hunk1 DATA: 44B template copied to lib private — contains the
  "graphics.library" name actually used (lib+0x44->str)

## Contents

- [functions/vectors.md](functions/vectors.md)
- [structures/layout.md](structures/layout.md)
- [findings/quirks.md](findings/quirks.md)
- [log.md](log.md)
