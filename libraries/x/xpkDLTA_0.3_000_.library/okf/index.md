---
type: Library
title: xpkDLTA 0.3(000)
description: >-
  XPK delta ('bytemode') filter packer; byte-differencing codec.
timestamp: 2026-10-15T00:00:00Z
---

# xpkDLTA 0.3(000)

XPK packer sublibrary implementing the XpksSub API (-30 XpksPackerInfo,
-36 XpksPackChunk, -42 XpksPackFree, -48 XpksPackReset,
-54 XpksUnpackChunk, -60 XpksUnpackFree; -42/-48/-60 and the reserved
-24 slot are stubs).

## Binary facts

- 720 bytes, single CODE hunk (600 bytes), md5
  `7c59a56bf765719b0e755acc854bfa4c`, sha256
  `f7ec7c45775c8a1fd3c6ff1b5a85f1d6b33008b7df18205f4a3eac4bbff41506`
- AUTOINIT library: InitTable dataSize 0x26, **word-offset** function
  table (0xffff marker; null slots are negative offsets back to the
  `moveq #0,d0/rts` entry stub at code+0)
- XpkInfo block and one XpkMode ("bytemode") as code data islands
- id string `$VER: xpkDLTA V0.3 (1 Oct 2013) by Stephan Fuhrmann`

## Status

DONE — BYTE-IDENTICAL reconstruction: `source/xpkDLTA_h0.s` builds with
`/opt/amiga/bin/m68k-amigaos-gcc -m68000` to md5 `7c59a56b...` (cmp
clean).  Runtime behaviour verified identical under machine68k
(`work/oracle.py`, orig.log == rebuild.log).  The earlier C model is
kept as `make cmodel` — correct semantics, not byte-identical.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [algorithms/codec.md](algorithms/codec.md)
- [findings/](findings/index.md)
- [log.md](log.md)
