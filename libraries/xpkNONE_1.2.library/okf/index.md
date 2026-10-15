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
- AUTOINIT XPK sublib (RomTag flags 0x80, v1 rev2); absolute-longword
  function table, 10 vectors (-6..-60), terminated by 0xffffffff
- Embedded XpkInfo block at code+0x15e + second param struct at
  code+0x20a ("normal" mode string)
- rt_EndSkip=0x102 ends the resident BEFORE the name/idstr strings
  and the whole XpkInfo island — resident scan cuts mid-rts
- Seglist cell is a code-island long at 0x7a (inside dead datatab
  zero space), written by initfn via an absolute-long move
- Expunge deferred-flag defect: when OpenCnt>0 it does
  `bset #3,$e(a6)` with a6=EXEC BASE (a5 holds the lib) — sets a bit
  in exec's node flags, so a later Close never triggers the real
  expunge; the lib is effectively un-expungeable via the normal path

## Status

DONE — verbatim asm `source/xpkNONE_v.s` + `source/fixup.py`
(reorders RELOC32 offsets to the original descending list).  `make`
produces a byte-identical 732B library (md5
56927e0ddec34be4998faff61ca18e2c); machine68k oracle
(`work/oracle.py`) trace-identical over init/all vectors/deferred +
real expunge.  Older C model kept under `make cmodel`.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
