# XpksUnpackChunk (-54, @0x2fe)

Decoder: `a0` = in, `a1` = out, `d0` = flag register.

## Flag mechanism

- d0 init `moveq #-128` (0x80) -> first `addb` yields 0+C,
  forcing a flag-byte load.
- Load: `moveb a0@+,d0` then `addxb d0,d0` -> register =
  `flag*2 + 1`; the +1 is a sentinel bit.  The flag byte's
  bit7 is the first item's type.
- Per item: `addb` shift -> carry = next bit.  When the low
  byte empties (sentinel shifted out, exactly 8 items) the
  `beq` reloads.  So one flag byte serves 8 items,
  MSB-first, 1 = match / 0 = literal.

## Items

- Literal (bit 0): `*dst++ = *src++`.
- Match (bit 1): read token byte `t`; `t == 0` -> done.
  `len = (t & 0xf) + 2` (3..17), `dist = (t & 0xf0) << 4 |
  next` (1..4095); copy `len` bytes from `dst - dist` via a
  computed-goto unrolled `moveb a2@+,a1@+` chain.

## Bounds

No output bound check at all: the decoder trusts the stream
(`xsp_OutLen` never written by this routine -- unlike the
encoder which does write it).
