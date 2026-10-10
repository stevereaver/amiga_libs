---
type: Library
title: xpkDLTA 0.3(000)
description: >-
  XPK delta ('bytemode') filter packer; first byte differenced against 0.
timestamp: 2026-10-10T21:55:00Z
---

# xpkDLTA 0.3(000)

XPK packer sublibrary implementing the XpksSub API (-30 XpksPackerInfo,
-36 XpksPackChunk, -42 XpksPackFree, -48 XpksPackReset,
-54 XpksUnpackChunk, -60 XpksUnpackFree; several slots stubbed).

## Binary facts

- sha256 f7ec7c45775c8a1fd3c6ff1b5a85f1d6b33008b7df18205f4a3eac4bbff41506
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
