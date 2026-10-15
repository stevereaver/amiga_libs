---
type: Library
title: xpkRLEN.library 1.1 (Nov 2 1992)
description: >-
  XPK "Run Length" packer sublibrary - PackBits-style RLE codec.
  Oldest RLEN build: Aztec-style two-hunk binary with a decorative
  RomTag and a self-relocating data template.
timestamp: 2026-10-15T08:10:00Z
---

# xpkRLEN.library 1.1

XPK packer sublibrary (`RLEN` 4CC).  Six user vectors implementing
the XpksSub API: PackerInfo, PackChunk (PackBits encoder),
PackFree/PackReset (stubs), UnpackChunk, UnpackFree.

## Binary facts

- 1384 bytes; TWO hunks: CODE 0x3a8 + DATA 0x114
- RomTag is decorative: rt_EndSkip = +0x1e (covers only the header),
  rt_Init points back at the RomTag itself.  The REAL InitTable sits
  at the start of the DATA hunk (dataSize 0x13a) - the xpk master
  finds it by convention, not via exec's InitResident.
- InitFunction copies the 256-byte data template into base+0x3a and
  applies 4 pointer fixups from an offset table at data+0x100.
- `$VER: RLEN 1.1 (Nov  2 1992)` lives in the DATA hunk (the CODE
  hunk's id string is just "Version 1.0").
- Entry stub returns 0 (not -1 like xpkNONE 1.4).

## API

| LVO | Symbol | Notes |
|-----|--------|-------|
| -30 | XpksPackerInfo | returns relocated template ptr (base+0xe0) |
| -36 | XpksPackChunk  | PackBits encoder |
| -42 | XpksPackFree   | stub - returns d0 unchanged |
| -48 | XpksPackReset  | returns 0 |
| -54 | XpksUnpackChunk| byte-loop decoder |
| -60 | XpksUnpackFree | stub - returns d0 unchanged |

## Status

FULL - reconstructed (source/), builds CODE+DATA two-hunk binary;
data hunk is byte-identical to shipped; code is a semantic port.

## Contents

- [functions/](functions/index.md) - [structures/](structures/index.md)
- [findings/](findings/index.md) - [algorithms/](algorithms/index.md) - [log.md](log.md)
