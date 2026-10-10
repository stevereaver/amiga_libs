---
type: Structure
title: FFPFormat
description: Motorola fast floating point encoding used by the SP* API.
---

# FFP format

All SP* arguments and results in d0 are Motorola fast
floating point, NOT IEEE 754:

```
MMMMMMMM MMMMMMMM MMMMMMMM SEEEEEEE
[31:8]  24-bit significand -- binary fraction, leading 1
        explicit in bit31, so m/2^24 is in [0.5, 1.0)
[7]     sign (1 = negative)
[6:0]   7-bit exponent, two's-complement excess-64
        (stored = real + 64, range $00..$7F <-> -64..+63)
```

value = (-1)^s * m/2^24 * 2^(e-64); 0 is all-zeros.

Examples: 1.0 = `0x80000041`, -1.0 = `0x800000C1`,
0.5 = `0x80000040`, 2.0 = `0x80000042`, 6.4 = `0xCCCCCC43`.

This is the classic C= mathffp/mathtrans format, distinct
from the IEEE-single API of mathieeesingtrans.library.
See okf/functions/SPTieee.md and SPFieee.md for the shipped
converters.
