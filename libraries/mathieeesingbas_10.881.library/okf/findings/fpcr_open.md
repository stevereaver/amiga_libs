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
   condition codes the caller left -- effectively random. The
   reconstruction implements the evident *intent* (`(UWORD)fpcr == 0`) and
   keeps the verbatim `0x40 <= fpcr < 0x80 -> rewrite` range check.
2. 0x80 = extended-precision + round-toward-zero FPCR mode. Open forces
   this when FPCR is 0 or already in the single-precision band 0x40..0x7f.

