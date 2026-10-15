---
type: Log
title: Work Log
description: Chronological journal of analysis sessions.
---

# Log

## 2026-10-15
- Hunk parse (work/hunk.py): CODE 0x2cd longs + DATA 0xb longs;
  relocs CODE: 48 h0 + 3 h1, DATA: 2 h0.  Bodies dumped to
  work/h0.bin / h1.bin.  IRA -M68000 disasm -> work/bitmap_a.asm
  (uses running addresses across sections — gen.py needs
  per-hunk base offsets when indexing body bytes).
- work/gen.py (from the xpkPWPK generator) emits gas + raw bytes;
  bitmap-specific fix: bare `MOVEA.L ABSEXECBASE,A6` assembled as
  absw (0x2c79 encodings) — forced `:l` long-form; IRA's relocated
  annotation column corrected to plain symbolic labels (stored
  values are hunk-relative, not absolute).
- source/bitmap_h0.s (.text + .data) -> link -> fixup.py verifies
  both hunk bodies + splices original two-group RELOC32 tails ->
  BYTE-IDENTICAL (md5 12107804a3928ea2b95e31f7720c94f1).
  Makefile uses -m68020: the code genuinely contains 68020
  scaled-index forms `movel a3@(0,d2:w:4),d2` etc. that gas
  rejects under -m68000.
- work/oracle.py: two-hunk loader + cross-hunk RELOC32, fake
  graphics.library (BltBitMap -30, InitBitMap -390,
  AllocBitMap -918, FreeBitMap -924) + exec stubs
  (OpenLibrary -> GFXB, CloseLibrary/Remove/FreeMem log,
  AllocMem bump).  GfxBase lib_Version patched 20<->39 to cover
  both alloc paths.  Exercised: initfn hunk1->lib+0x30 copy,
  open x2, null -24, all 8 functions (alloc/free both gfx paths,
  row table build/free, putpixel/getpixel round-trip ->0x5a,
  putrun, scaler x3 flag paths + degenerate), deferred expunge
  (flags 0x0e observed), real expunge -> Remove+seglist.
  orig.log == rebuild.log -> RUNTIME-IDENTICAL.
