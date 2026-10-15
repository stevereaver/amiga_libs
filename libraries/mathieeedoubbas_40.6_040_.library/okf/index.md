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

Sibling of `mathieeedoubbas_40.6_FPU_` — semantically the same
Berndt framework with the SAME math vector bodies (still executes
`faddd`/`fsubd`/`fmuld`/`fdivd` natively and relies on the 68040
FPSP for the unimplemented `fintrz`/`fint` used by IEEEDPFloor and
IEEEDPFix's `fmove.l`), but **NOT byte-identical**: the idstring
is 4 bytes longer, shifting every functab target +4, and the init
gate is extended.  CORRECTION to the earlier note: the whole
functab/vector region differs at the byte level.

## Binary facts

- sha256 `e0037e320cc356114edddcb3426339b88d340874ebb68f2752dbdc675ba91637`, 900 bytes
- single CODE hunk 0x2f0 bytes
- RomTag: RTF_AUTOINIT, RT_VERSION 40, NT_LIBRARY
- name `mathieeedoubbas.library`; idstring
  `mathieeedoubbas 40.6 (7.4.95) for 68040\r\n(c) 1995 by Martin Berndt`
- InitTable: dataSize 0x2c, absolute-longword functab (16 + -1L)
- init gate: `btst #3` AFF_68040 required; under exec
  `lib_Version >= 39` additionally `btst #6` AFF_FPU40
  (oracle-verified: attn=0x08 passes alone only on exec<39)
- private DELEXP flag: bit3 of base+0x2a (not lib_Flags)

## Status

**BYTE-IDENTICAL** — verbatim asm `source/mdb040_v.s` +
`source/fixup.py` (splices the original 26-entry ascending
RELOC32 tail; the verbatim source is all-literal so gas emits
no relocs). md5 `d57f6a32940f2862519712f0376aa9b7`.
machine68k oracle `work/oracle.py` (adapted from the FPU
sibling's: line-F emulates the 68881/82 subset the 040 FPSP
would supply) — RUNTIME-IDENTICAL over the 8-case init-gate
matrix (attn x exec version), open x2, all 16 vectors with
edge inputs, reserved -24 (points at code+0 stub), and
deferred + real expunge.  C model kept as `make cmodel`.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
