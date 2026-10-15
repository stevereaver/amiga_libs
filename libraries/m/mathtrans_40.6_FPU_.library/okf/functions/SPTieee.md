---
type: Function
title: SPTieee
description: FFP -> IEEE single converter at LVO -102.
---

# SPTieee — LVO -102

`float SPTieee(d0 parm)` — converts an FFP value in d0 to the
numerically equal IEEE single in d0.

FFP layout `MMMMMMMM MMMMMMMM MMMMMMMM SEEEEEEE`:
24-bit significand (leading 1 explicit, fraction point left of
bit31), sign at bit7, 7-bit exponent in excess-64 two's
complement.  `add.l d0,d0` doubles the sign+exp field out of
the low byte (the leading mantissa 1 exits as carry);
`eori.b/asr.b/subi.b #0x82` re-biases the exponent into the
IEEE +127 domain; `swap`+`rol.l #7` parks sign at bit31, the
8 exponent bits at [30:23], and the 23 mantissa fraction bits
at [22:0].  FFP 0 short-circuits to IEEE 0 via `beq`.

Unlike the sibling mathieeesingtrans 40.6 build, this is a
real converter — the SP* API of mathtrans is FFP, not IEEE.
