---
type: Library
title: xpkNONE 1.2
description: >-
  XPK store/dummy packer; pack returns XPKERR_EXPANSION, unpack CopyMems.
timestamp: 2026-10-10T21:55:00Z
---

# xpkNONE 1.2

XPK packer sublibrary implementing the XpksSub API (-30 XpksPackerInfo,
-36 XpksPackChunk, -42 XpksPackFree, -48 XpksPackReset,
-54 XpksUnpackChunk, -60 XpksUnpackFree; several slots stubbed).

## Binary facts

- sha256 b847f8b0180137b2ce760631025b6e9dcdd7d55348a4b65fb0ebfdf765c92d47
- Non-AUTOINIT XPK sublib; absolute-longword function table
- Embedded XpkInfo block + XpkMode entries (documented in structures/)

## Status

FULL - reconstructed C source builds a valid hunk library
(m68k-amigaos-gcc -m68000).  Algorithm: pass-through store.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
