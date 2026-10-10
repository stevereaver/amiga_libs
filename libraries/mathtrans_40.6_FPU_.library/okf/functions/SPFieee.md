---
type: Function
title: SPFieee
description: IEEE single -> FFP converter at LVO -108.
---

# SPFieee — LVO -108

`float SPFieee(d0 parm)` — converts an IEEE single in d0 to
FFP in d0.

`swap`+`ror.l #7` lands the IEEE exponent in byte0, the sign
at bit8, and the 23 fraction bits at [31:9].  The byte ops
`eori.b #0x80 / add.b d0,d0 / addq.b #5 / eori.b #0x80`
re-bias the exponent into FFP excess-64 form, then
`ror.l #1` merges sign and exponent into the low byte
(sign -> bit7, exponent -> [6:0]) — the classic
`MMMMMMMM MMMMMMMM MMMMMMMM SEEEEEEE` FFP layout.

Range checking: `bvs` after the doubled exponent byte enters
an edge-case tree.  In-range exponents produce FFP values;
out-of-range magnitudes (IEEE exponent too large, incl.
infinities) return `0xFFFFFFFF` with the V flag set;
underflows clamp to FFP 0.  IEEE 0 returns FFP 0 through the
`andi.w #0xfeff`/`tst.l`/`beq` clear path.
