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
- md5 `0b7251cd2ae0bdfe0719761b54a6eb0b`
- single CODE hunk 0x2e4 bytes
- RomTag: RTF_AUTOINIT, RT_VERSION 40, NT_LIBRARY, pri 0;
  RT_ENDSKIP = RT_INIT = hunk+0x7e -> the InitTable itself
  (mid-module quirk, same family trait as singtrans/mathtrans)
- name `mathieeedoubbas.library`; idstring
  `mathieeedoubbas 40.6 (7.4.95) for 68881/82\r\n(c) 1995 by Martin Berndt`
- module entry `moveq #0,d0/rts` (also ExtFunc target)
- InitTable: dataSize 0x2c, absolute-longword functab (16
  entries + -1L), InitStruct datatab, initFunc
- InitStruct: NT_LIBRARY, flags 0x06, version 40, revision 6
- init: clears OpenCnt, stores SysBase/SegList, requires
  AFF_68020 && AFF_68881
- Open writes FPCR=0x90 (double precision, round-to-zero)
- private DELEXP flag: bit3 of base+0x2a (not lib_Flags)

## Status

BYTE-IDENTICAL + RUNTIME-IDENTICAL — `make` assembles
`source/mdb406_v.s` (verbatim asm, raw .short for all F-line
words) and links `-nostdlib -Wl,-s` to the shipped 896-byte
module (md5 `0b7251cd2ae0bdfe0719761b54a6eb0b`); the earlier
C framework stays buildable as `make cmodel`.  machine68k
oracle (`work/oracle.py`, python 68881 emulation through the
line-F vector) runs identical logs on the original and the
rebuild — init gate matrix, open/close/expunge lifecycle,
all 16 vectors incl. edge inputs.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
