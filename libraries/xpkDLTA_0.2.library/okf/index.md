---
type: Library
title: xpkDLTA 0.2
description: >-
  XPK delta ('ByteMode') filter packer; byte-differencing codec with
  cross-chunk carry.
timestamp: 2026-10-15T00:00:00Z
---

# xpkDLTA 0.2

XPK packer sublibrary implementing the XpksSub API (-30 XpksPackerInfo,
-36 XpksPackChunk, -42 XpksPackFree, -48 XpksPackReset,
-54 XpksUnpackChunk, -60 XpksUnpackFree; -42/-48/-60 and the reserved
-24 slot are stubs).

## Binary facts

- 720 bytes, single CODE hunk (600 bytes), md5
  `db80a6f55766ec0e670a7a78b441920e`, sha256
  `727f69b8a10ac1934e283b06711e2c4ec15cc46cc4a01212db211959256123dd`
- AUTOINIT library: InitTable dataSize **0xfc** — the XpkInfo and
  XpkMode descriptors live INSIDE the library base and are written by
  the InitStruct table (byte offsets may exceed 0x7f)
- **word-offset** function table (0xffff marker); the four null slots
  point at a shared `moveq #0,d0/rts` inside XpksPackChunk
- id string `xpkDLTA.library v0.2` (no `$VER` cookie), lib version 0.2
- reloc32 tail stored in DESCENDING order (toolchain quirk —
  `source/fixup.py` rewrites it post-link)

## Status

DONE — BYTE-IDENTICAL reconstruction: `source/xpkDLTA_h0.s` +
`source/fixup.py` builds to md5 `db80a6f5...` (cmp clean).  Runtime
behaviour verified identical under machine68k (`work/oracle.py`,
orig.log == rebuild.log).  The earlier C model is kept as
`make cmodel` — near-correct semantics (but misses the shipped
off-by-one, see findings/Quirks.md), not byte-identical.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [algorithms/codec.md](algorithms/codec.md)
- [findings/](findings/index.md)
- [log.md](log.md)
