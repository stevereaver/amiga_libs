---
type: Finding
title: FPCR write in Open
description: Open programs the 68881 control register (0x80 (conditional)).
---

# FPCR write in Open

The shipped Open does `fmove.l fpcr,d0; beq write; cmpi.w #0x40,d0;
bcs keep; cmpi.w #0x80,d0; bcc keep; write: fmove.l #0x80,fpcr`.

Two observations:

1. `fmove.l fpcr,d0` does NOT set CCR, so the shipped `beq` tests whatever
   condition codes the caller left -- effectively random. Byte-exact
   reconstruction keeps the verbatim sequence; the oracle exercises the
   branch both ways by presetting Z (work/oracle.py).
2. 0x80 as an FPCR mode byte = rounding-precision *double* +
   round-to-nearest (PREC=10, RND=00).  Open writes it when the stale-Z
   beq happens to fire, or when the FPCR low word is in 0x40..0x7f.
   The intent was presumably to normalise the FPU rounding state on
   first Open.

