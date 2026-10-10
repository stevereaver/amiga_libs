---
type: Finding
title: Quirks
description: Oddities found in the shipped binary.
timestamp: 2026-10-10T22:30:00Z
---

# Quirks

- **Private DELEXP byte**: the deferred-expunge flag is bit3 of a
  private byte at base+0x2a — `lib_Flags`/`LIBF_DELEXP` is never
  touched.  Works because exec never inspects DELEXP itself, but
  it deviates from the textbook convention (filed as an
  inconsistency).
- **Identity conversion vectors**: IEEESPTieee and IEEESPFieee
  share one functab entry pointing at a bare `rts` — FFP↔IEEE
  conversion is a no-op in this IEEE-native build.  Callers that
  genuinely need an FFP value get the IEEE input back.
- **Module entry triples as a vector**: the `moveq #0,d0; rts`
  loader entry is also the LVO -24 (ExtFunc) target AND
  IEEESPPow's error exit for x<0/non-integer-y.
- **68020 gate**: init requires AFF_68020 *and* AFF_68881 —
  failing on a theoretical 68000+68881 machine (the code itself
  is 68000-clean except this check).
- **No NoFPU fallback**: unlike the 10.881 line, a missing FPU
  just fails init rather than loading `Libs:NoFPU/...`.
- **InitStruct sets flags+revision**: lib_Flags=0x06 and
  lib_Revision=6 come from the datatab, not from code.
- idstring has no trailing `\r\n` (unusual for Amiga libs).
