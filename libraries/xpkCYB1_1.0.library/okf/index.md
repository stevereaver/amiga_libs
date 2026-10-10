---
type: Library
title: xpkCYB1 1.0
description: >-
  XPK CYB1 sublibrary; ships only XpksPackerInfo - pack/unpack vectors are stubs.
timestamp: 2026-10-10T21:55:00Z
---

# xpkCYB1 1.0

XPK packer sublibrary implementing the XpksSub API (-30 XpksPackerInfo,
-36 XpksPackChunk, -42 XpksPackFree, -48 XpksPackReset,
-54 XpksUnpackChunk, -60 XpksUnpackFree; several slots stubbed).

## Binary facts

- sha256 7a616cc0770a628098dbcc994c3d09f59fad104626e07f87cda22a33081b270b
- Non-AUTOINIT XPK sublib; absolute-longword function table
- Embedded XpkInfo block + XpkMode entries (documented in structures/)

## Status

FULL - reconstructed C source builds a valid hunk library
(m68k-amigaos-gcc -m68000).  Algorithm: info-only stub.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
