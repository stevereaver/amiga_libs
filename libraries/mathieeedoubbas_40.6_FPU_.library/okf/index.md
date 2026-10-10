---
type: Library
title: mathieeedoubbas.library 40.6 (7.4.95) "for 68881/82"
description: >-
  Third-party FPU rebuild of the IEEE double basic math library
  by Martin Berndt: 12 vectors, FPU ops moved through the stack,
  integer-only Cmp/Tst/Abs/Neg, FPCR-mode IEEEDPFix and a
  round-toward--inf Floor; private DELEXP flag byte at base+0x2a.
timestamp: 2026-10-10T23:00:00Z
---

# mathieeedoubbas.library 40.6 (7.4.95) for 68881/82

Sibling of `mathieeesingtrans_40.6_FPU_` — same Martin Berndt
framework (AUTOINIT, absolute-longword functab, 0x2c-byte base,
AFF_68020+AFF_68881 gate, private DELEXP byte) with the twelve
`IEEEDP*` basic-math vectors from the NDK fd (bias 30).

## Binary facts

- sha256 `43c0188441834a9132568210261edba58e166dbbb5d3ecdc198dd93134133586`, 896 bytes
- single CODE hunk 0x2e4 bytes
- RomTag: RTF_AUTOINIT, RT_VERSION 40, NT_LIBRARY, pri 0
- name `mathieeedoubbas.library`; idstring
  `mathieeedoubbas 40.6 (7.4.95) for 68881/82\r\n(c) 1995 by Martin Berndt`
- module entry `moveq #0,d0/rts` (also ExtFunc target)
- InitTable: dataSize 0x2c, absolute-longword functab (16
  entries + -1L), InitStruct datatab, initFunc
- InitStruct: NT_LIBRARY, flags 0x06, version 40, revision 6
- init: clears OpenCnt, stores SysBase/SegList, requires
  AFF_68020 && AFF_68881
- private DELEXP flag: bit3 of base+0x2a (not lib_Flags)

## Status

FULL — reconstructed (`source/`): C framework + integer vectors,
verbatim 68881 vectors in math.s; m68k-amigaos-gcc -m68020
-m68881, single-pass link.  FPU encodings verified against the
original disassembly.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
