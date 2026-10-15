---
type: Library
title: xpkRLEN 1.3
description: >-
  XPK PackBits-style run-length chunk packer (v1.3, 01.04.1997).
timestamp: 2026-10-10T22:40:00Z
---

# xpkRLEN 1.3

XPK packer sublibrary implementing the XpksSub API (-30 XpksPackerInfo,
-36 XpksPackChunk, -42 XpksPackFree, -48 XpksPackReset,
-54 XpksUnpackChunk, -60 XpksUnpackFree; three slots stubbed).

## Binary facts

- sha256 8c5bbdc3f3f57e874b1a09ff40cea41f292bc5b4caaa88df9366a1798437d493
- 1008 bytes, **two hunks**: hunk0 CODE (0x2a0 b) + hunk1 DATA (0x84 b)
- AUTOINIT RomTag (version 1), absolute-longword function table
- idstring `xpkRLEN 1.3 (01.04.1997)\r\n` — no `$VER:` tag
- XpkInfo/XpkMode descriptors live in the data hunk; their name
  pointers relocate back into the code hunk's string table
- dataSize 0x22 = bare `struct Library`; the seglist is kept in a
  code-space longword slot (self-referencing data), not in the base

## Status

BYTE-IDENTICAL + RUNTIME-IDENTICAL — hand asm `source/xpkRLEN_h0.s`
(+ fixup.py rewriting the RELOC32 groups to the shipped binary's
scrambled order) builds md5 `91531faa9caaff395ba3b5bbdd7996c2`,
matching the original exactly.  `make cmodel` still builds the
earlier C reconstruction (larger hunk0).  machine68k oracle
(`work/oracle.py`) exercises all 10 vectors, the cross-hunk
XpkInfo/XpkMode descriptors, codec round-trip + edge cases, and
the deferred-expunge defect — orig and rebuild logs identical.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
