---
type: Library
title: xpkFRLE.library V1.2 "Fast Run Length Encoder V1.2"
description: >-
  Jorma Oksanen's 2013 rewrite of the FRLE XPK chunk packer.
  Same XOR-obfuscated ByteRun stream format as V1.1 but a new
  implementation: computed-goto unrolled 32-byte stores in the
  decoder, sliding 3-byte window scanner in the encoder, and a
  compact resident layout where the hunk+0 stub is shared as
  the null vector and return trampoline.
timestamp: 2026-10-11T01:30:00Z
---

# xpkFRLE.library V1.2

XPK chunk packer ("Fast Run Length Encoder V1.2", 1 Oct 2013,
Jorma Oksanen).  V1.2 is a from-scratch rewrite, not an
incremental patch of V1.1:

- entry stub is `moveq #0,d0/rts` (V1.1 returned -1); the four
  unused functab slots are NEGATIVE word offsets back to hunk+0
- RomTag RT_ENDSKIP = 0 (V1.1 pointed at the hunk end)
- idstring carries a proper `$VER:` cookie
- decoder replaces byte loops with two computed-goto blocks of
  32 unrolled stores and NEVER writes xsp_OutLen
- encoder bounds output by OutBuf + InLen and never reads
  xsp_OutBufLen; InLen==0 returns -17 after OOB reads
- InitStruct rev 2; XpkInfo drops all four message strings and
  sets MaxPkInChunk=0x7fffffff, MinPkInChunk=0, DefMode=100;
  XpkMode Ratio 48%, speeds 370/1150, "normal"
- the hunk ends with an unterminated "EVE" tag

## Binary facts

- 984 bytes, single CODE hunk (0x370 bytes data)
- RomTag at hunk+0x04: RTF_AUTOINIT(0x80), ver 1, NT_LIBRARY,
  EndSkip 0, name->0x1e, idstr->0x2e, init->0x62
- InitTable hunk+0x62: dataSize 0x26, word-offset functab
  (hunk+0x92: -1 marker + 10 entries + -1), datatab->0x72,
  initFunc->0xaa
- InitStruct: NT_LIBRARY, flags 6, ver 1, rev 2
- XpkInfo 88 B at hunk+0x2ae, XpkMode 42 B at hunk+0x306
- strings at hunk+0x330..; "EVE" at 0x36d (no terminator)

## Status

FULL — reconstructed (`source/`): C framework + codecs
(xpkFRLE.c), resident tables/descriptors/strings
(xpkFRLE_lib.s), two-pass word-offset functab.  Host-verified:
30k random round-trips (expansion rejects and the shipped
>128-byte literal-tail corruption both reproduced), inlen==0
and n==1 edges checked.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [algorithms/](algorithms/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
