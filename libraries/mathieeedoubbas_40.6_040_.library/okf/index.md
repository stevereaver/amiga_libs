---
type: Library
title: mathieeedoubbas.library 40.6 (7.4.95) "for 68040"
description: >-
  Martin Berndt's 68040 build of the IEEE double basic math
  library — ships the identical 68881 code as the "FPU" sibling
  (fintrz/fint trap to the 68040 FPSP); init gate requires
  AFF_68040 plus AFF_FPU40 under exec v39+.
timestamp: 2026-10-10T23:10:00Z
---

# mathieeedoubbas.library 40.6 (7.4.95) for 68040

Sibling of `mathieeedoubbas_40.6_FPU_` — **the vector code is
byte-identical** to the 68881/82 build: this "68040" library
still executes `faddd`/`fsubd`/`fmuld`/`fdivd` natively but relies
on the 68040 FPSP for the unimplemented `fintrz`/`fint` used by
IEEEDPFloor and by IEEEDPFix's `fmove.l`.  Only the idstring,
the init gate, and internal table layout differ.

## Binary facts

- sha256 `e0037e320cc356114edddcb3426339b88d340874ebb68f2752dbdc675ba91637`, 900 bytes
- single CODE hunk 0x2f0 bytes
- RomTag: RTF_AUTOINIT, RT_VERSION 40, NT_LIBRARY
- name `mathieeedoubbas.library`; idstring
  `mathieeedoubbas 40.6 (7.4.95) for 68040\r\n(c) 1995 by Martin Berndt`
- InitTable: dataSize 0x2c, absolute-longword functab (16 + -1L)
- init gate: `btst #3` AFF_68040 required; under exec
  `lib_Version >= 39` additionally `btst #6` AFF_FPU40
- private DELEXP flag: bit3 of base+0x2a (not lib_Flags)

## Status

FULL — reconstructed (`source/`): same C framework + math.s
vectors as the FPU build, adapted init gate; builds with
m68k-amigaos-gcc -m68020 -m68881.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
