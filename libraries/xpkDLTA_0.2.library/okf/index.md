---
type: Library
title: xpkDLTA 0.2
description: >-
  XPK delta ('bytemode') filter packer.
timestamp: 2026-10-10T21:55:00Z
---

# xpkDLTA 0.2

XPK packer sublibrary implementing the XpksSub API (-30 XpksPackerInfo,
-36 XpksPackChunk, -42 XpksPackFree, -48 XpksPackReset,
-54 XpksUnpackChunk, -60 XpksUnpackFree; several slots stubbed).

## Binary facts

- sha256 727f69b8a10ac1934e283b06711e2c4ec15cc46cc4a01212db211959256123dd
- Non-AUTOINIT XPK sublib; absolute-longword function table
- Embedded XpkInfo block + XpkMode entries (documented in structures/)

## Status

FULL - reconstructed C source builds a valid hunk library
(m68k-amigaos-gcc -m68000).  Algorithm: byte-delta filter.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
