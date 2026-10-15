---
type: Algorithm
title: AutoSize mode selection
---
# AutoSize

For xsp_Mode > 90 the packer zeroes xsp_Sub[0..2], runs
all three encoders into the same output buffer, and keeps
the smallest nonzero OutLen:

- LongByte or WordByte winner: re-encoded for real
- ByteByte winner: already in the buffer (it ran last)
- all three failed: -17

Preference on equal sizes: LongByte < WordByte < ByteByte.
The trial OutLens remain visible in xsp_Sub[0..2].
