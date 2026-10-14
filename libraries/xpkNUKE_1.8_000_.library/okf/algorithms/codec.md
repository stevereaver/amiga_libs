---
type: Algorithm
title: NUKE 1.8 pack/unpack stream format
timestamp: 2026-10-15T00:00:00Z
---

# Output stream layout

Identical format to NUKE 1.9 — four interleaved forward bit streams
written to `outcur`-relative slots plus one backward literal region
descending from `dst+outmax` toward `outcur`:

1. flag stream (1 bit/token: 1 = match, 0+1 = single literal,
   0+0 = counted literal run)
2. 2-bit stream (literal-run counts, match-length extension)
3. nibble stream (offset-class code 4-bit, long-length extension)
4. xbits stream (offset residual bits, variable width)

Each stream has its own accumulator + bit counter + pending-slot
pointer (ptr1..ptr4); partial words are finished by the final flush
at code+0x66e..0x6ac.

# Class/offset tables (code+0x6f4..0x79b)

- seltab @0x6f4 = {0,0,4,10}: indexed by min(len-1,3) -> word offset
  into the threshold lists.
- Threshold lists @0x6fc: len<=1 -> {0x10,0x40,0x100,0x200};
  len==2 -> {0x10,0x80,0x200,0x800,0x2000,0x4000};
  len>=3 -> {0x20,0x80,0x200,0x800,0x2000,0x4000} (lists overlap).
- nbtab @0x71c = residual bit counts {4,6,8,9,4,7,9,11,13,14,
  5,7,9,11,13,14}; codetab @0x73c = identity nibbles 0..15;
  basetab @0x75c = cumulative bases
  {0,0x10,0x50,0x150, 0,0x10,0x90,0x290,0xa90,0x2a90,
   0,0x20,0xa0,0x2a0,0xaa0,0x2aa0};
  copytab @0x77c = {0x20 x4, 0x1e x6, 0 x6} jump offsets into the
  decoder copy block.

# Match encoding

Flag `1`; the class walk subtracts thresholds while `d3 >= *at`, then
emits the class nibble (put4) + residual bits (putx).  Length:
`len<=5` -> 2-bit code `~(len-3)&3` (len 3,4,5 -> 3,2,1);
`len>5` -> 2-bit `0` then `15`-nibble runs + `~rem&15` nibble.

# Match search

Same hash-chain search as 1.9: `tab1[pair]` = newest position for the
byte pair, `tab2[pos]` = previous link; `tab2[0]` is re-seeded with
`d5` as the self-loop sentinel; candidates are byte-tested against
the drifting compare base; `cmpw d4,d6; bls` (lower-or-same) rejects
the sentinel and out-of-window candidates.  Matches of len<=1 with
offset >= 336 are rejected back to literal.  Every emitted match
hash-updates all covered positions.

# Decoder (code+0x79c)

Forward reads on the four streams + backward literal reads; same
observable format as 1.9 but a more compact implementation — the
nibble extension dispatch `jmp pc@(0x880,d0:w)` enters the 15-moveb
block mid-way (nibble n copies 16-n bytes; n=0 copies 15 and loops),
and the copy-dispatch table jumps into the shared 3-byte prologue /
2-bit extension block at 0x810/0x82e/0x830/0x832.  Literal-run
dispatch at 0x86a -> {+3 loop, +4, +3, +2} for codes {0,1,2,3} —
same semantics as 1.9 despite the different code layout.
