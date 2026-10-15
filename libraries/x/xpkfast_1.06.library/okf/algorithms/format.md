# xpkFAST 1.06 stream format

Same wire format as 1.2 — the two versions interoperate.

```
[ literal bytes ... ][ pad ][ backward region ]
```

- **Literals** are appended forward starting at out+0.
- **Control words and match tokens** are 16-bit big-endian
  words pushed *downward* from a top cursor:
  - speedy:   `ctop = (out + InLen) & ~3`  (absolute address
    alignment — differs from 1.2's `out + (InLen & ~3)` when
    `out` is not 4-aligned)
  - crawling: `ctop = out + (InLen & ~3)`
- Each ctrl word carries the type bits of up to 16 items, MSB
  first: bit=0 -> literal, bit=1 -> match.
- **Token** = `(offset<<4) | nibble`, offset 1..0xfff.  The
  decoder computes `len = 18 - nibble` (len 3..18).  The speedy
  packer writes `18-len` directly; the crawler writes
  `17-len_field` where `len_field` = number of compares
  executed = len-1 — identical on the wire.

## Flag-register mechanics

Packer side (both packers): a flag register accumulates one bit
per item via a shift; carry/X out of bit15 means the word is
full -> store at the reserved slot and reset the seed.

- Speedy uses `d3` seeded `0xffff` per word: literal does
  `asl.w`, match does `rol.w` (old bit15 re-enters at bit0 —
  still 1 while <= 16 items accumulate).
- Crawler uses `d7` seeded 1: literal leaves X=0 after `asl.w`,
  match path rehashes through `asl.l` chains that leave X=1 —
  `addx.w d7,d7` then injects the flag bit.  Carry-out stores
  the word.

Decoder side: `d1` starts `0x8000`; `add.w d1,d1` -> X=1.
Reload does `move.w -(a4),d1; addx.w d1,d1` — consumes bit15 as
the next item bit and shifts the X sentinel into bit0.  Each
item pops bit15 leftward; a popped 1 that empties `d1` is the
*sentinel* — it triggers the `a0 >= a4` boundary check and a
reload.  **Two of the four paths omit the `d1==0` exhaustion
check** — see defects.

## Tail compaction (pk_finish)

After the last item, the pending flag accumulator is rotated
until the sentinel carries out, then stored at the reserved
slot.  `gap = cw - litend`:

- `gap < 0`  -> return 0; the wrapper maps this to -17
  (literal/control streams collided).
- `gap >= 0` -> append `gap & 3` zero pad bytes (DBF loop; **can
  be ZERO pad bytes** — 1.2 wrote `(gap&3)+1`), then copy the
  whole backward region down behind the literals, word-wise.
  Return `o - outbuf` as `xsp_OutLen`.

Backward region memory order (top->bottom):
`W1, W1's tokens, W2, W2's tokens, ...` — decode order.  The
compactor slides it down so the file order is exactly what
`-(a4)` walks.
