---
type: Library
title: xpkRLEN 1.5(000)
description: >-
  XPK PackBits-style run-length chunk packer.
timestamp: 2026-10-10T21:55:00Z
---

# xpkRLEN 1.5(000)

XPK packer sublibrary implementing the XpksSub API (-30 XpksPackerInfo,
-36 XpksPackChunk, -42 XpksPackFree, -48 XpksPackReset,
-54 XpksUnpackChunk, -60 XpksUnpackFree; several slots stubbed).

## Binary facts

- sha256 d475f20b3d0bdfb79ca1bc000922c2d63c4d7f37a4cb5c3d32f86eae8e2d15f3
- Non-AUTOINIT XPK sublib; absolute-longword function table
- Embedded XpkInfo block + XpkMode entries (documented in structures/)

## Status

FULL - reconstructed C source builds a valid hunk library
(m68k-amigaos-gcc -m68000).  Algorithm: PackBits RLE.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
