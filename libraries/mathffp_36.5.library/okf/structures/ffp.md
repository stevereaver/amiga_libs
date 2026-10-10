# FFP (Fast Floating Point) format

    31            8  7      6          0
    [ mantissa (24) ][sign][ exponent (7) ]

- mantissa: unsigned 24-bit binary fraction, normalized so bit
  31 is set → value in [0.5, 1.0).
- sign: bit 7 (a *byte* sign, not the normal IEEE bit 31).
- exponent: bits 6..0, biased 64 → value = ±mant/2^24 *
  2^(exp-64).
- zero: 0x00000000. A nonzero mantissa with exp byte 0 is a
  *denormal* — routines generally pass it through unmodified
  rather than normalizing.

Useful constants:

| value | encoding   |
|-------|------------|
| 0.5   | 0x80000040 |
| 1.0   | 0x80000041 |
| 2.0   | 0x80000042 |
| -1.0  | 0x800000c1 |
| +inf-ish saturation | 0xffffff7f |
| -inf-ish saturation | 0xffffffff |

## Add/sub byte packing

The exponent byte holds sign|exp. Both operands' bytes are
doubled in the WORD domain (`add.w`/`add.b`) so the sign bit
moves to bit 8; `^0x80` rebases. Signed byte arithmetic on the
doubled exponents gives overflow detect (V) for the
+/-64-biased domain; `ror.w #1` / `lsr.w #1` folds the result
sign (from byte1 bit0 = sA^sB) into bit 7.

## Library base (dataSize 0x22 = plain struct Library)

Only `lib_OpenCnt` (@32), `lib_Flags` (@14, DELEXP=bit3) and
the Node link fields (@0..7) are used at runtime; InitStruct
fills type/name/flags/version/revision/idstring.
