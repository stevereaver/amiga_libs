---
type: Library
title: mathieeedoubtrans.library 40.6 "for 68881/82"
description: >-
  Martin Berndt's IEEE-double transcendental math library
  (68881/82 required).  Seventeen thin FPU wrappers in the
  stack-shuffle convention (d0:d1 double args pushed, fXXXd
  on the stack image, result popped back) plus a real
  IEEEDPPow and Tieee/Fieee float<->double converters.
timestamp: 2026-10-11T02:10:00Z
---

# mathieeedoubtrans.library 40.6 (FPU build)

IEEE double-precision transcendental library ("mathieeedoubtrans
40.6 (7.4.95) for 68881/82", "(c) 1995 by Martin Berndt").
Sibling of mathieeedoubbas 40.6 and mathieeesingtrans 40.6 --
same Martin Berndt framework:

- entry `moveq #0,d0/rts` doubles as ExtFunc (returns 0)
- AUTOINIT RomTag ver 40, absolute-longword functab,
  dataSize 0x2c
- private DELEXP byte at base+0x2a bit3 (NOT lib_Flags)
- init gate AFF_68020 && AFF_68881 (btst pair this build;
  note 68882-only machines have bit5 set, not bit4, despite
  the "68881/82" idstring)
- doubles passed as d0:d1 pairs through the stack

## Binary facts

- 1000 bytes, single CODE hunk (0x338 bytes data)
- RomTag at hunk+0x04, EndSkip->InitTable (0x82)
- InitTable: dataSize 0x2c, functab 21 entries + -1L
- idstr "mathieeedoubtrans 40.6 (7.4.95) for 68881/82
"
  + "(c) 1995 by Martin Berndt" copyright
- vectors at hunk+0x194..0x336 -- BYTE-EXACT reconstruction
  (all FPU encodings verified identical)

## Status

FULL — reconstructed (`source/`): framework in C
(mathieeedoubtrans.c), resident/InitTable/functab in
mathieeedoubtrans_lib.s + datatab.s, all 17 vector bodies in
math.s (the whole 0x194..0x336 region byte-identical to the
shipped code).  Framework is semantically equivalent
(btst-pair gate compiles to andi/cmpi).

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
