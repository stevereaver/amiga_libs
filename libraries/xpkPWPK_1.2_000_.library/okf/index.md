---
type: Library
title: xpkPWPK 1.2(000)
description: >-
  XPK sublibrary wrapping powerpacker.library (PowerPacker) —
  hash-chain LZ77 codec with literal/match bit writer, per-mode hash
  widths, optional userdata-keyed XOR crypt + checksum trailer.
timestamp: 2026-10-15T00:00:00Z
---

# xpkPWPK 1.2(000)

XPK packer sublibrary implementing the XpksSub API (-30
XpksPackerInfo, -36 XpksPackChunk, -42 XpksPackFree, -54
XpksUnpackChunk; -24/-48/-60 are stubs returning 0).

## Binary facts

- 3184 bytes, single CODE hunk (0x2fe longs = 3064 bytes), md5
  `41affc8a958ef52dcf35dc4ceb6ae9eb`, sha256
  `9564582e65dff91ef7aa5c7ba1d0b6c09c1d79057c6e624c1596d92dae19aebe`
- AUTOINIT library: InitTable dataSize 0x26, **word-offset** function
  table (0xffff marker; null slots are negative offsets back to the
  `moveq #0,d0/rts` entry stub at code+0)
- XpkInfo descriptor at code+0xa9a: name `xpkPP`, desc "Based on
  powerpacker.library", longname "PowerPacker 1.2", sign `PWPK`,
  flags 0x2a009; 5-entry XpkMode chain
  Fast/Mediocre/Good/Very Good/Best (upto 20/40/60/80/100,
  pspd 18/17/14/11/9)
- id string `$VER: xpkPWPK V1.2 (1 Oct 2013) by Michael Barsoom`
- 17 RELOC32 entries into hunk0 (RomTag 4, InitTable 3, datatab 2,
  XpkInfo/mode-chain pointers 8)

## Status

DONE — BYTE-IDENTICAL reconstruction: `source/xpkPWPK_h0.s` builds
with `/opt/amiga/bin/m68k-amigaos-gcc -m68000` to md5 `41affc8a...`
(cmp clean).  Runtime behaviour verified identical under machine68k
(`work/oracle.py`, orig.log == rebuild.log) covering init, all 10
vectors incl. pack/unpack round-trips, userdata crypt+checksum path,
corrupt-trailer -32, ctx free, deferred+real expunge.

## Contents

- [functions/vectors.md](functions/vectors.md)
- [structures/layout.md](structures/layout.md)
- [algorithms/codec.md](algorithms/codec.md)
- [findings/quirks.md](findings/quirks.md)
- [log.md](log.md)
