---
type: Function
title: SPTieee
description: FFP to IEEE-single converter, LVO -102.
---

# SPTieee — LVO -102

Shared helper AND public vector: converts the FFP
(Motorola fast floating point: 24-bit significand,
sign at bit7, excess-64 exponent) value in d0 to IEEE
single in d0.  Identical routine to the FPU sibling
build; used as the prologue of every numerical
vector.
