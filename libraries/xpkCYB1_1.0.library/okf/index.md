---
type: Library
title: xpkCYB1 1.0
description: >-
  XPK CYB1 sublibrary; ships only XpksPackerInfo - all pack/unpack
  vectors share a single "movel #-1,d0; rts" stub (return -1).
timestamp: 2026-10-15T00:00:00Z
---

# xpkCYB1 1.0

XPK packer sublibrary implementing the XpksSub API (-30 XpksPackerInfo,
-36 XpksPackChunk, -42 XpksPackFree, -48 XpksPackReset,
-54 XpksUnpackChunk, -60 XpksUnpackFree).  Only -30 is real; the
reserved -24 vector is a `moveq #0,d0/rts` and every packer slot
returns -1 — an info-only sublibrary.

## Binary facts

- 752 bytes, single CODE hunk (588 bytes), md5
  `51c68810ef67538e734e291c15493bd8`, sha256
  `7a616cc0770a628098dbcc994c3d09f59fad104626e07f87cda22a33081b270b`
- AUTOINIT library (rt_Flags 0x80), lib version 1.0
- **absolute-longword** function table, 10 vectors + -1 terminator
  (same format as xpkNONE 1.2)
- XpkInfo + XpkMode live as a static data island in the code hunk
  (hunk+0x164 / hunk+0x224), not in the library base
- dataSize 0x4a: Library node + xsb_SysBase(+0x22) + xsb_SegList(+0x26)
- reloc32 tail ascending — GNU ld order matches, no fixup needed

## Quirks

- `rt_EndSkip` == `rt_Init` (hunk+0x78) — resident scan runs into the
  InitTable itself
- `lib_IdString` points at hunk+0x33, *inside* the version string past
  the `$VER:` prefix (id has no `$VER` cookie of its own)
- InitStruct writes NT_LIBRARY(9) to base+0x0c, not ln_Type(+0x08) —
  and the write is dead anyway: the following INITLONG at base+0x0a
  (ln_Name) clobbers +0x0c.  ln_Type stays 0 in the built node.
- Expunge pulls SysBase out of the library base (+0x22), not abs-4.

## Status

DONE — BYTE-IDENTICAL reconstruction: `source/xpkCYB1_h0.s` (verbatim
GNU-as) builds to md5 `51c68810...` (cmp clean, no fixup pass needed).
Runtime behaviour verified identical under machine68k
(`work/oracle.py`, orig.log == rebuild.log).  The earlier C model is
kept as `make cmodel` — not byte-identical.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
