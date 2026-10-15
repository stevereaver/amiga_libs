---
type: Function
title: SPLog
description: FFP natural logarithm, LVO -84.
---

# SPLog — LVO -84

`float SPLog(d0 parm)` — FFP arg, FFP result.

frexp-style split: the IEEE exponent is extracted by
bit manipulation, the mantissa normalized to
[sqrt(1/2), sqrt(2)) (constant 0x3fe6a09e667f3bcc =
sqrt(1/2)), then `_log_core` runs a rational
approximation in z = (m-1)/(m+1); result is
e*ln2 + log(m).  x<=0 returns the IEEE NaN pattern
(0x7fffffffffffffff) internally -> FFP error.
