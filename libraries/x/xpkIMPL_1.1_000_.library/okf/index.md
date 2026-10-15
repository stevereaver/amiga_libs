---
type: Library
title: xpkIMPL 1.1(000)
description: >-
  xpk sub-library by Peter Struijk (1 Oct 2013): Turbo Imploder
  compressor ('xpkIM'/'IMPL' sign, flags 0x8009) — Imploder
  "dynamic compression modes" codec, 12 XpkModes (mode 0-11,
  upto 9-100, pspd 22->4), optional userdata XOR crypt +
  checksum trailer.
timestamp: 2026-10-15T00:00:00Z
---

# xpkIMPL.library 1.1(000)

idstring `$VER: xpkIMPL V1.1 (1 Oct 2013) by Peter Struijk`.
md5 `09dafe4002ec6449ef2c7bc9a1a86e6b`.

## Layout

- Single CODE hunk, 0xce8 bytes; 28 ascending RELOC32.
- AUTOINIT resident; InitTable @+0x62 (dataSize 0x26), InitData
  @+0x72, word-offset functab @+0x92 (leading+trailing ffff).
- XpkInfo descriptor block @+0xa1c: name 'Imploder', lname
  'Turbo Imploder V1.1', sign IMPL, flags 0x8009, 12 modes.

## Vectors (10)

-6 Open, -12 Close, -18 Expunge (deferred via flags bit 3,
Remove+FreeMem), -24/-42?/-48/-60 stubs -> hunk0+0 ret0,
-30 XpksPackerInfo, -36 XpksPackChunk ('IMP!' trailer),
-42 XpksPackFree, -54 XpksUnpackChunk.

## Status

BYTE-IDENTICAL - verbatim asm `source/xpkIMPL_h0.s` + `fixup.py`
(md5 `09dafe4002ec6449ef2c7bc9a1a86e6b`).  machine68k oracle
identical over initfn, open x2, stubs, XpkInfo + 12-mode walk,
pack incompressible -17 bail, mode-0 pack w/ IMP! trailer,
userdata-crypt pack, unpack round-trip + corrupt-trailer -30-ish
path, ctx free, deferred + real expunge.
