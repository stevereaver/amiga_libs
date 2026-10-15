---
type: Library
title: xpkCBR0 1.2(000)
description: >-
  XPK IFF ByteRun-style chunk packer.
timestamp: 2026-10-15T00:00:00Z
---

# xpkCBR0 1.2(000)

XPK packer sublibrary implementing the XpksSub API (-30 XpksPackerInfo,
-36 XpksPackChunk, -42 XpksPackFree, -48 XpksPackReset,
-54 XpksUnpackChunk, -60 XpksUnpackFree; -42/-48/-60 and the reserved
-24 slot are stubs).  Codec: ByteRun1 RLE — n>=0 emits n+1 literals,
n<0 emits the next byte -n+1 times; the encoder caps look-ahead at 125.

## Binary facts

- 804 bytes, single CODE hunk (700 bytes), md5
  `0243e290e331815dceb75ed3df6ccbed`, sha256
  `aaf246d27b0d0408d90f7ff0ec7fd89797c05e8d7b24634e160032a486bfcd9c`
- AUTOINIT library (rt_Flags 0x80), lib version 1.2
- **word-offset** function table (0xffff markers, signed word offsets
  from table start, same as xpkNONE 1.5 / xpkDLTA 0.3); the four null
  slots decode to hunk+0 — the entry stub `moveq #0,d0; rts` doubles
  as the null vector
- XpkInfo + XpkMode live as a static data island in the code hunk
  (hunk+0x1f6 / hunk+0x24e)
- dataSize 0x26: Library node + seglist only — no saved SysBase;
  expunge loads exec base from absolute 4
- reloc32 tail ascending — GNU ld order matches, no fixup needed

## Quirks

- `rt_EndSkip` = 0 (resident scan not bounded)
- In the InitTable the datatab pointer (+0x6a) precedes the functab
  pointer's target (+0x8a) — datatab is stored before functab
- XpksPackChunk bounds output by OutBuf+InLen, ignoring
  xsp_OutBufLen entirely; overflow returns -17.  Incompressible
  (pure-literal) input always overflows that bound, as does
  zero-length input.
- Close falls through into the expunge vector entry on last close.

## Status

DONE — BYTE-IDENTICAL reconstruction: `source/xpkCBR0_h0.s` (verbatim
GNU-as) builds to md5 `0243e290...` (cmp clean, no fixup pass needed).
Runtime behaviour verified identical under machine68k
(`work/oracle.py`, orig.log == rebuild.log): real pack/unpack
round-trips incl. repeat runs, literal runs, zero-length and the -17
overflow path.  The earlier C model is kept as `make cmodel` — not
byte-identical.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
