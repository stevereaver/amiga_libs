# xpkFAST stream format

```
[ literal bytes ... ][ pad ][ backward region ]
```

- **Literals** are appended forward starting at out+0.
- **Control words and match tokens** are 16-bit big-endian words
  pushed *downward* from `out + (InLen & ~3) - 2`.
- Each ctrl word carries the type bits of up to 16 items, MSB
  first: bit=0 → literal, bit=1 → match.
- **Token** = `(offset<<4) | (18-length)`, offset 1..0xfff,
  length 3..18 (nibble = 18-len, so len 18 → nibble 0).

## Sentinel mechanics

Packer side: `d6` (bits) starts at 1; each item does
`addx.w d6,d6` (literal) or `ori #0x10;addx.w` (match, carry set
first).  When bit 16 carries out, the word is stored at the
current slot and `d6` resets to 1.

Unpacker side: `d1` starts `0x8000`, `add.w d1,d1` → X=1.
Reload does `move.w -(a3),d1; addx.w d1,d1` — consumes bit15 as
the next item bit and shifts the X sentinel into bit0.  Each
item then shifts `d1` left; a shifted-out 1 that leaves `d1==0`
is the *sentinel*, not an item — it triggers the boundary check
(`cmpa.l a3,a0` — literal cursor vs ctrl cursor) and reload.
This is why all-zero control-word tails decode correctly: the
sentinel, not the bit pattern, marks exhaustion.

## Tail compaction (pk_tail)

After the last item the pending ctrl accumulator is shifted
until the sentinel carries out, then stored at the slot.
`gap = cw - dataend`:

- `gap < 0` → return -17 (output overrun; caller falls back).
- `gap == 0` → done, `xsp_OutLen = o - outbuf`.
- `gap > 0` → append `(gap & 3) + 1` zero pad bytes, then copy
  the whole backward region forward.  The copy is the
  bit-cascade `lsr/bcc` copier: bit1→word, bit2→long,
  bit3→2 longs, bit4→4 longs, then 8-long pairs —
  `copied = size & ~1`, so an odd trailing byte would be
  dropped (unreachable: region is always even).

Backward region memory order (top→bottom):
`W1, W1's match tokens, W2, W2's tokens, ...` — decode order.
The tail copier replicates it forward so the file order is
exactly what `-(a3)` walks.
