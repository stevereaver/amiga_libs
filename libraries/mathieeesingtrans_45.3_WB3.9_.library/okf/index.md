---
type: Library
title: mathieeesingtrans.library 45.3 (23.11.2000) - WB3.9
description: >-
  IEEE single-precision transcendentals (exp/log/sqrt/trig) -
  WB3.9-era combined build probing fpsp.resource then AttnFlags
  for a 3-way functab (software / 68881 / 68040-fpsp).
timestamp: 2026-10-15T11:15:00Z
---

# mathieeesingtrans.library 45.3 (WB3.9)

Single-precision transcendental math.  RTF_COLDSTART (non-AUTOINIT);
rt_Init -> init code which probes OpenResource("fpsp.resource") +
AttnFlags and selects one of three word-offset functabs - the
same combined-build pattern as mathieeedoubbas_45.3.

## Binary facts

- 6844 bytes; single CODE hunk 0x1a60
- RomTag flags 0x01 (COLDSTART), v45, NT_LIBRARY
- opens `mathieeesingbas.library` + `fpsp.resource`

## API

16 single-trans vectors (-30..-120): SPAtan, SPDise, SPCos,
SPCosH, SPExp, SPFieee, SPLog, SPLog10, SPPow, SPSin, SPSinCos,
SPSinH, SPSqrt, SPTan, SPTanH, SPTieee.

## Status

FULL - byte-identical rebuild (verbatim h0.s + fixup.py).

## Contents

- [functions/](functions/index.md) - [findings/](findings/index.md) - [log.md](log.md)
