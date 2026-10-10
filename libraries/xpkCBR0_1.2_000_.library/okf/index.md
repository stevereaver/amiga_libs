---
type: Library
title: xpkCBR0 1.2(000)
description: >-
  XPK IFF ByteRun-style chunk packer.
timestamp: 2026-10-10T21:55:00Z
---

# xpkCBR0 1.2(000)

XPK packer sublibrary implementing the XpksSub API (-30 XpksPackerInfo,
-36 XpksPackChunk, -42 XpksPackFree, -48 XpksPackReset,
-54 XpksUnpackChunk, -60 XpksUnpackFree; several slots stubbed).

## Binary facts

- sha256 aaf246d27b0d0408d90f7ff0ec7fd89797c05e8d7b24634e160032a486bfcd9c
- Non-AUTOINIT XPK sublib; absolute-longword function table
- Embedded XpkInfo block + XpkMode entries (documented in structures/)

## Status

FULL - reconstructed C source builds a valid hunk library
(m68k-amigaos-gcc -m68000).  Algorithm: ByteRun1 RLE.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
