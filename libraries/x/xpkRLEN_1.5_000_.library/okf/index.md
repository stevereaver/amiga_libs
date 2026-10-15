---
type: Library
title: xpkRLEN 1.5(000)
description: >-
  XPK PackBits-style run-length chunk packer, 804 bytes, single code
  hunk. AUTOINIT library with a word-offset function table, $VER
  cookie, rt_EndSkip=0, and a rewritten dbra-scan encoder that refuses
  to expand (ceiling = OutBuf + InLen).
tags: [xpk, sublibrary, packer, rle, autoinit]
timestamp: 2026-10-15T00:00:00Z
---

# xpkRLEN 1.5(000)

XPK packer sublibrary implementing the XpksSub API (-30 XpksPackerInfo,
-36 XpksPackChunk, -42 XpksPackFree, -48 XpksPackReset,
-54 XpksUnpackChunk, -60 XpksUnpackFree; -24/-42/-48/-60 point back at
the hunk-0 entry stub).

## Binary facts

- sha256 d475f20b3d0bdfb79ca1bc000922c2d63c4d7f37a4cb5c3d32f86eae8e2d15f3
- md5 `e0f7d2275b0331a7a0c86f88123671ed`
- **AUTOINIT** (rt_Flags=0x80) XPK sublib with a **word-offset**
  function table — an earlier note here claimed non-AUTOINIT with an
  absolute-longword table; that was wrong.  The word-offset table
  sits at hunk+0x98 between the datatab and the code, and its dead
  slots carry offset -0x98 back to the hunk-0 `moveq #0,d0/rts` stub.
- rt_EndSkip is a literal 0 (no reloc); IdString carries a real
  `$VER:` cookie: `$VER: xpkRLEN V1.5 (1 Oct 2013) by Urban Dominik
  Muller\r\n`.
- One CODE hunk, 0x2bc bytes, 13 RELOC32 entries already in
  ascending order (GNU ld emits the same order — no fixup needed).
- Static XpkInfo (hunk+0x1fe) + XpkMode "normal" (hunk+0x256)
  islands; InitTable dataSize is just 0x26 (Library + seglist).

## Status

DONE — byte-identical + runtime-identical. `make` in `source/`
assembles the verbatim `xpkRLEN_h0.s` and `cmp` + md5sum verify
identity. The earlier C model remains buildable as `make cmodel`.
`work/oracle.py` (machine68k) exercises init, all ten vectors,
Pack/Unpack, zero-length and -17 edges and deferred+real expunge;
orig-vs-rebuild logs are identical.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
