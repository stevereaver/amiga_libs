---
type: Finding
title: FFPConventions
description: The SP* API is FFP, verified by host round-trip tests.
---

# FFP conventions (verified)

The mathtrans SP* API operates on Motorola FFP values, unlike
the IEEE-single mathieeesingtrans family.  Verified by
host-simulating the shipped converters:

```
FFP 0x80000041 (1.0)   -> IEEE 0x3f800000  roundtrip OK
FFP 0x80000040 (0.5)   -> IEEE 0x3f000000  roundtrip OK
FFP 0x80000042 (2.0)   -> IEEE 0x40000000  roundtrip OK
FFP 0xC0000041 (1.5)   -> IEEE 0x3fc00000  roundtrip OK
FFP 0x800000C1 (-1.0)  -> IEEE 0xbf800000  roundtrip OK
FFP 0xCCCCCC43 (6.4)   -> IEEE 0x40cccccc  roundtrip OK
IEEE 0                 -> FFP 0
IEEE +-inf / huge      -> 0xFFFFFFFF (V set)
```

Every math vector is `SPTieee(arg) -> one 68881 single op ->
fmoves + SPFieee(result)`.  SPSincos converts the cosine
first (stored through d1) and returns the sine in d0.
