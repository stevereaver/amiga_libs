# algorithms

## DMC (Cormack-Horspool) coding

Binary arithmetic coder (24-bit range, carry-less -- no E1/E2/E3
mapping, just `if (lo>=hi) hi=0x1000000`) over an adaptive state
machine. Each state has two transition targets and two float counts.
Per bit:

1. `P0 = f[ctx][0] / (f[ctx][0] + f[ctx][1])` in fp regs
2. range-narrow by P0 (encoder: by bit; decoder: split vs code)
3. `update(bit)`: if `f[ctx][bit] >= 10` AND
   `sum(target) - f[ctx][bit] >= 10` -> **clone** target into a
   fresh slot: clone freq = target freq x `f[ctx][bit]/sum(target)`,
   target keeps the remainder; clone transitions = {self on `bit`,
   target's other link}; then `f[ctx][bit] += 1.0` and descend
   `ctx = link[ctx][bit]`.
4. byte-renormalize: emit/absorb `(lo>>16)` while `hi-lo < 256`

The arithmetic is done on the 68881: `fmovel` conversions are
round-to-nearest (so splits are `round`, not `floor`), counts are
32-bit singles, ratios in extended.

## Stream format

`[4B unpacked length][arith bitstream][3-byte lo flush]`; decoder
reads exactly `len` bytes and stops -- no end marker.
