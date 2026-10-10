---
type: Library
title: mathieeesingtrans.library 40.6 (7.4.95) "for 68881/82"
description: >-
  Third-party FPU rebuild of the IEEE single transcendental math
  library by Martin Berndt: 17 one-instruction 68881 vectors, a
  real IEEESPPow with sign fixup, identity Tieee/Fieee stubs,
  and a private DELEXP flag byte at base+0x2a.
timestamp: 2026-10-10T22:30:00Z
---

# mathieeesingtrans.library 40.6 (7.4.95) for 68881/82

Single-hunk AUTOINIT library: a clean-room-ish FPU build of the
IEEE single transcendental math library, credited "(c) 1995 by
Martin Berndt".  Where the Kickstart 1.x 10.881 builds carry a
NoFPU fallback and a larger base, this build is minimal: a
0x2c-byte base, AttnFlags gating on AFF_68020+AFF_68881, and
seventeen vectors that are each a single 68881 instruction.

## Binary facts

- sha256 `f6c26ce0242cce01aad91fc96d54b9b3847589ddb3329fab31775edd7893662f`, 816 bytes
- hunks: single CODE hunk 0x280 bytes
- RomTag: RTF_AUTOINIT, RT_VERSION 40, NT_LIBRARY, pri 0
- idstring: `mathieeesingtrans 40.6 (7.4.95) for 68881/82\r\n(c) 1995 by Martin Berndt` (no trailing CRLF)
- module entry: `moveq #0,d0/rts` (doubles as IEEESPPow's error exit)
- InitTable: dataSize 0x2c, **absolute-longword** functab,
  InitStruct datatab, initFunc
- InitStruct writes ln_Type=9, ln_Name, lib_Flags=6,
  lib_Version=40, lib_Revision=6, lib_IdString
- init clears OpenCnt, stores SysBase/seglist, requires
  AFF_68020 && AFF_68881 (btst #1/#4 on the flags low byte)
- 21 vectors + -1L: Open, Close, Expunge, ExtFunc→module entry,
  17 math stubs; IEEESPTieee and IEEESPFieee share one bare rts
- private DELEXP flag: bit3 of base+0x2a (not lib_Flags)

## Status

FULL — reconstructed (`source/`): C framework + verbatim 68881
vectors in math.s; m68k-amigaos-gcc -m68020, single-pass link
(absolute functab).  FPU encodings verified instruction-for-
instruction against the original.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [algorithms/](algorithms/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
