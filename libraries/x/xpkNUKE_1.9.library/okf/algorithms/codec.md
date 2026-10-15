---
type: Algorithm
title: NUKE pack/unpack stream format
timestamp: 2026-10-14T00:00:00Z
---

# Output stream layout

The packer maintains **four interleaved forward bit streams** written
to `outcur`-relative slots plus one **backward literal region** that
descends from `dst+outmax` toward `outcur`:

1. flag stream (1-bit per token: literal-run vs match)
2. 2-bit stream (offset-class select / length short-codes)
3. nibble stream (offset-class code, 4-bit; literal high bits)
4. xbits stream (residual offset bits, variable width)

Each stream has its own accumulator + bit counter + pending-slot
pointer (ptr1..ptr4); a partial word is left open at the slot and
finished by the final flush (`wr16/wr32` at code+0x67c).

# Literal encoding

Flag `0` then a run length: single bit for <4, else 2-bit groups +
terminating nibble (`~(rem)&15`).  Literal bytes are written
*backwards* at `litptr--` while tokens advance `outcur` forwards.

# Match encoding

Flag `1`, then offset class via the table at code+0x17c (contiguous:
`clstab[16]` limits, `+16` residual-bit counts, `+32` nibble codes,
indexed by `seltab_48c[min(len-1,3)]`), residual bits in xbits, then
length: `len<=5` → 2-bit code `~(len-3)&3` (len 3,4,5 → 3,2,1);
`len>5` → 2-bit `0` then `15`-nibble runs + `~rem&15` nibble.

# Match search (the subtle part)

- `tab1[pair]` = most recent position with that byte pair;
  `tab2[pos]` = previous position (chain head->tail by recency).
- Per position, `tab2[0]` is seeded with `d5` as a sentinel.
- Candidates are byte-tested against a **drifting** compare base a2
  (advances to `d2` on every accepted better match), then compared
  with `cmpm.b (a5)+,(a1)+` against the target.
- On a better match: `cmp.w d4,d6; bls done` — **lower-or-same**,
  so candidate `d6=0` (empty chain / position 0) is always rejected
  when `d4=0`, and out-of-window candidates (`d6 <= d5-window`) end
  the search.  This gate, not a `<`, is what keeps the sentinel from
  emitting bogus long matches.
- `d4 = d5 - window` (word) clamped to 0 via moveq when the `sub.w`
  borrows.
- After the loop: `offset = end_of_match - match_start`; length vs
  `srcend` clamp; matches of len<=1 with offset >= 336 are rejected
  back to literal (`code+0x462`).
- Every emitted match also hash-updates all covered positions
  (`tab2[d5]=tab1[h]; tab1[h]=d5`), first entry uses the unshifted
  pair — the loop enters *past* the `h<<8|byte` shift.

# Decoder

Forward reads on the four streams + backward literal reads; mode
table at code+0x1dc drives class reconstruction.  Round-trips every
stream the packer emits (except inputs whose match positions exceed
16 bits — see findings).
