---
type: Library
title: xpkNUKE 1.1
description: >-
  Earliest surviving xpkNUKE (Nov 2 1992) — XPK sublibrary with an
  embedded LZ packer/unpacker, two hunks (CODE+DATA), and an init
  routine that copies the whole data hunk into the library's private
  area and self-relocates eight block-relative pointers.
timestamp: 2026-10-15T00:00:00Z
---

# xpkNUKE 1.1

XPK packer sublibrary exposing the XpksSub API (10 vectors).
Codec "NUKE": hash-chain LZ77 emitting four interleaved forward bit
streams (flag / 2-bit / nibble / extra-bits) plus a backward-written
literal region, reassembled at flush time.  Short name `NUKE`,
"A relatively efficient packer that unpacks very quickly".

## Binary facts

- md5 `bb4257fa0250c2259f600754808843da`; 3296 bytes
- HUNK_HEADER: 2 hunks — CODE hunk0 0x2bd longs (2804B body),
  DATA hunk1 0x50 longs (320B body)
- RELOC32 hunk0: 16 -> hunk0 (functab 0xaa4..0xac8 + RomTag/init
  string refs 0x5a,0x42,0x16,0x12,0xa,0x6), 2 -> hunk1
  (rt_Init at 0x1a, data-hunk base imm at 0x66)
- RELOC32 hunk1: 2 -> hunk0 (InitTable functab +0x8, initfn +0x10)
- AUTOINIT RomTag @hunk0+0x04 (flags 0x80, ver 1, type 9, pri 0),
  rt_EndSkip 0x1e; name "xpkNUKE.library" @0xad0,
  id "Version 1.0" @0xae0 (not the $VER string!)
- rt_Init -> data+4: InitTable {dataSize 0x156, funcTab->code+0xaa4
  (absolute longs, -1 term), dataTab NULL, initFn -> code+0x20}
- initFn copies data hunk [0..0x11b] to lib+0x3a and adds lib+0x3a
  to the 8 block-relative pointer slots listed at data+0x120
  (count long at data+0x11c)
- data hunk: "$VER: NUKE 1.1 (Nov  2 1992)", XpkMode "normal" at
  +0x32, XpkInfo at +0xc4, msg strings, reloc-offset table +0x120
- XpkInfo (lib+0xfe): ver 1, libv 1, masterv 0, modesv 1,
  name "NUKE", long "Nuke 1.0", ID 'NUKE', flags 9,
  max/def chunk 0x7530, min 0xa, DefMode 0x32,
  msgs Nuking/Unnuking/Nuked/Unnuked

## Status

FULL — verbatim gas reconstruction `source/xpkNUKE_h0.s` +
`xpkNUKE_h1.s` (-m68020) byte-identical (fixup.py splices the
original RELOC32 tails); machine68k oracle-identical over resident
init, all 10 vectors, 20-stream pack corpus + unpack round-trips,
workspace reuse, PackFree, -17/-7 error paths, deferred and real
expunge.

## Contents

- [functions/](functions/vectors.md)
- [structures/](structures/layout.md)
- [algorithms/](algorithms/codec.md)
- [findings/](findings/quirks.md)
- [log.md](log.md)
