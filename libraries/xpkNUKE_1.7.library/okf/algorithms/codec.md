---
type: Algorithm
title: NUKE 1.7 pack/unpack stream format
timestamp: 2026-10-14T00:00:00Z
---

# Output stream layout

Same four-stream multiplexed format as 1.9.  The packer maintains
**four interleaved forward bit streams** written via `outcur`-based
pending slots plus one **backward literal region** that descends
from `dst+outmax` toward `outcur`:

1. flag stream — word accumulator, MSB-first, 1 bit per token:
   `1` = match; `0` = literal run.  A literal run is immediately
   followed by the next match flag/emit (no separator).
2. 2-bit stream — word accumulator: literal-run count codes and the
   short match-length codes (classes 10-15 extension).
3. nibble stream — long accumulator `rorl #4` based: offset-class
   code nibble, then the long-match extension nibbles.
4. xbits stream — long accumulator `asll|v` based: residual offset
   bits (variable width per class).

Each stream has its own counter (w+44..50), accumulator
(w+52..63) and pending-slot pointer (w+64..79) seeded to the
12-byte scratch at w+80; the final flush (0x6b8) shifts the
accumulators into the open slots (stream3 flushes `acc >> ctr`,
streams 1/2/4 flush `acc << ctr`).

# Literal encoding (flush_lit @ 0x200)

Emits flag `0`, copies `litcnt+1` source bytes starting at
`src+litstart-1` forward into the backward literal area
(`moveb a0@+,a1@-`), then emits the count: if `litcnt==0` → flag
`1` (single literal); else flag `0` + 2-bit groups: for each full
3 literals `put2(0)` (`d0-=3`), then terminator `put2((-d0)&3)`
→ remaining 1,2,3 encode as 3,2,1.  Resets `litcnt=-1` on entry.

# Match encoding (emit @ 0x426)

Pending literals flush first (flag `0` + count) or a bare flag `1`
when `litcnt<0`.  Then the offset class: `d0 = min(len_code,3)`
selects `seltab_138[d0]` (4 words at code+0x138) giving a sub-table
inside `clstab` (code+0x140): 16 word bases are subtracted in turn
(`while d3 >= *at: d3 -= *at++`), leaving the residual `d3`;
`at[32]` is the class nibble → nibble stream, `at[16]` is the
residual bit count → xbits stream.  Then the length code
(`len_code = match_len-1` here): `len_code<=5` → 2-bit
`(~(len_code-3))&3`; `>5` → 2-bit `0`, then `put4(0)` per 15, and
`put4((~rem)&15)`.

# Match search (pack_core @ 0x2fa)

- `tab1[pair]` = most recent position with that byte pair;
  `tab2[pos]` = previous position with the same pair (chain by
  recency).  `tab2[0]` is seeded with `d5` per search as sentinel.
- RLE fast path: when `src[d5-1]==src[d5]` and the run from
  `src+d5+1` extends >2 (`d2>2` after srcend clamp), emit
  len=`runlen-1`, off=1 — and bump `litcnt` for the run's first
  position before emitting.
- General search walks the chain testing `a2[d6+1]` (drifting base
  a2, advances by `a1-d2` on every accepted better match) against
  `d7` = the byte after the current best end; full compare with
  `cmpm.b` only when the filter passes.
- **Window-edge gate**: on a better match at candidate `d6`,
  `cmp.w d4,d6; bls done` — branch *lower-or-same* terminates the
  search **without** recording the match.  `d4 = d5 - window` or 0
  if `d5 <= window`.  So candidate `d6=0` (chain terminator /
  position 0) is *always* discarded (`0 <= 0`), and candidates at
  or below the window edge stop the walk.  (An earlier draft of the
  reconstruction used `<` — that admits pos-0 matches and diverges;
  `ramp` differs at the last two emits.)
- Lazy tab2 clear: when `d5 > window` (strictly), clear
  `t2front..tab2+2*(d5-window)` as longs and advance t2front.
- Reject: `len_code<=1 && off>=336` → `tab2[d5]=tab1[pair]` then
  literal (which sets `tab1[pair]=d5` — together a normal push).
- Emit: pushes ALL covered positions `d5..d5+d2` into the chains
  (`tab2[d5]=tab1[h]; tab1[h]=d5`), rolling the pair
  (`h = (h<<8)|src[d5+1+i]`).  First push uses the main-loop pair
  before any shift; `d5` lands one past the last covered position.
- Loop bound is signed: `(SHORT)d5 < (SHORT)lastpos`.

# Finish + tail (0x696 / 0x6fa)

pack_finish bumps `litcnt` twice if `d5 != inlen` (the running
position plus the virtual end literal), flushes the run, drains
all four accumulators.  pack_tail fails with -1 **only** when
`litptr - outcur < 0` (strictly past — equality is OK here; 1.9
fails at equality too), then 0xfb-pads `outcur` so the literal run
lands long-aligned and copies `nlits` bytes forward.

# Decoder (unpack_core @ 0x73c)

Forward reads of the four streams + backward literal reads.
Notably dispatches both the copy counts and the 2-bit codes through
`jmp %pc@(tab,d0:w)` jump tables (0x79c/0x7b8/0x844 with bases at
0x160..0x1ff), where 1.9 uses compare chains — same semantics,
different codegen.  Register contract from the wrapper: a5=stream
read head (forward), a4=packed end (literal reads, backward),
a0=out write, a2=out end; returns final a0 in d0 (discarded).
