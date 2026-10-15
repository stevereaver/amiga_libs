---
type: Library
title: xpkLHLB 1.2
description: >-
  XPK sublibrary implementing a self-contained LZ-variant codec
  (id "LHLB", 8.12.2010) — unlike xpkLHLB 1.1 it no longer opens
  or delegates to lh.library; the whole packer/unpacker is embedded.
timestamp: 2026-10-15T00:00:00Z
---

# xpkLHLB 1.2

XPK packer sublibrary exposing the XpksSub API (10 vectors).
info string claims "preprocessor for lh.library" but the binary
contains no `lh.library` name and init issues no OpenLibrary —
the codec is fully embedded (68020 asm, hash-table driven LZ
with a 40000-byte stream state and 36864-byte staging buffer;
unpack uses a 4500-byte state).

## Binary facts

- md5 d17bbb8c808cbde4af634a33768657bf; 3176 bytes
- single CODE hunk, 0x2ff longs (3068B body), no reloc entries
  needed beyond what the hunk carries; HUNK framing preserved by
  fixup.py
- AUTOINIT RomTag @+0x04 (ver 1 rev 2, flags 06)
- InitTable @+0x1e: dataSize 0x30, word-offset functab @+0x2e
  (leading+trailing 0xffff), datatab @+0x46, initfn @+0x160
- name "xpkLHLB.library" @+0x80; id "xpkLHLB 1.2 (8.12.2010)\r\n"
- XpkMode @+0xde: upto=100 flags=1 desc="normal"
- XpkInfo @+0x108: libv=1 masterv=1 flags=9 maxchunk/defchunk
  0x8000, defmode=100; xi_LibVersion=1
- static lookup tables inside the hunk at +0x57a..+0x7f6 and
  +0xb04..+0xb84 (emitted raw in the reconstruction)
- dataSize 0x30: bare lib + seglist + SysBase + spare

## Status

FULL — verbatim gas reconstruction `source/xpkLHLB_h0.s`
(-m68020) is byte-identical (fixup.py preserves original HUNK
framing) and machine68k oracle-identical over module entry, init,
all 10 vectors, chained pack, unpack round-trip, free vectors,
error paths, and deferred+real expunge.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [algorithms/](algorithms/index.md)
