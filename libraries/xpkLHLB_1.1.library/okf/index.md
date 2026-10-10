---
type: Library
title: xpkLHLB 1.1
description: >-
  XPK sublibrary adapter delegating chunk compression to lh.library.
timestamp: 2026-10-10T23:05:00Z
---

# xpkLHLB 1.1

XPK packer sublibrary implementing the XpksSub API on top of
lh.library ("LHL preprocessor for lh.library").  LibInit opens
`lh.library` (version 1); the codec LVOs lazily allocate an lh
control block (lh -30) plus a 36 KiB scratch buffer and delegate
pack/unpack to lh vectors -42/-48.

## Binary facts

- sha256 77de403663720c732e52e7a2fd504a5c17962558410a9781c422eccd1d98a2b9
- 1020 bytes, single code hunk
- AUTOINIT RomTag (version 1), absolute-longword function table
- idstring `xpkLBLB 1.1 (5.4.98)\r\n` -- "LBLB" typo is in the binary
- dataSize 0x30: bare lib + seglist + SysBase + lhbase
- XpkInfo/XpkMode embedded in the code hunk
- Requires `lh.library` on the target system; refuses to init
  without it (self-frees the allocated base)

## Status

FULL - reconstructed C source builds a valid hunk library
(m68k-amigaos-gcc -m68000).  The codec is a pure adapter: all
stream semantics belong to lh.library.  Framework semantics
verified against the shipped disassembly; the lh calls use the
identical vectors/registers.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
