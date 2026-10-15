# Input vectors

## AFHexValue (-30, @ 0x1b8)

Hex char in d0 -> nibble in d0. Accepts `0-9`, `A-F`.
For letters subtracts 7 then masks `&0x0f` -- so `@` (`0x40`)
would fold to 9 were it not range-checked (it is, so only
`A-F` pass). Carry flag set on invalid input; callers use `bcs`.
Other CCR bits reflect the last `andb`.

## AFGetChar (-48, @ 0x23c)

`FGetC` (-306) on the handle in a1 (dosbase at base+0x28).
Post-process: result 0x9b (CSI lead-in of a console escape
sequence) is mapped to 0 -- swallows one half of a CSI pair
but leaves the following byte. Returns byte in d0.

## AFGetHexChar (-54, @ 0x262)

Reads a char via -48, echoes it via -72 (FPutC+Flush),
uppercases `a-z` (subtract 32), then hex-parses via -30.
Carry set on non-hex. Echo happens BEFORE validation, so
bad input is echoed too.

## AFCharAvail (-60, @ 0x2a0)

`WaitForChar` (-204) with timeout 1 microsecond -- a
non-blocking "is a key waiting" poll.

## AFReadHex (-66, @ 0x2bc)

Accumulates digits: `value = value*16 + nibble`, `count++`
per digit until the first non-hex char. Returns
d0 = terminating char, d1 = value, d2 = count.
Exits with carry set in all cases (the terminator is
non-hex by construction) -- the flag is meaningless here.
