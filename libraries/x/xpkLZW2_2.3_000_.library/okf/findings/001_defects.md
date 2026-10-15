# Findings -- shipped defects and inconsistencies

## 1. PackReset underflows the workmem block by 5,040 bytes

`XpksPackReset` clears DOWNWARD from `sub + 0x10000` with
pre-decrement `movem` frames: 16 + 252x280 = 70,576 bytes.
The intended region is the 65,536-byte hash table -- the
fill overruns 5,040 bytes BELOW `sub`:

- zeroes the AllocMem size word at `sub-4`, so a
  subsequent `XpksPackFree` executes `FreeMem(blk, 0)`
  and the entire 320 KB workmem LEAKS;
- clobbers ~5 KB of whatever heap happens to sit below
  the block -- a heap-corruption landmine on real systems.

Same defect class as xpkLZW3 3.3 (which underflows only
68 bytes -- still enough to hit the size word).  V2.3 is
dramatically worse.

## 2. Chain ring is never initialised

PackReset clears only the hash region (and, accidentally,
the heap below it).  The 256 KB chain ring at
sub+0x10000 is left holding whatever AllocMem returned.
Benign in practice: chain entries are only reached through
hash buckets (which are zeroed -> chain walk stops),
and stale ring entries are only read once a real position
has been hashed into that slot.  Across PackReset reuse
the stale entries can seed phantom candidates pointing at
old input buffers -- harmless for output correctness
(dist >= 0x10000 or bytes differ -> rejected) but a latent
aliasing hazard.

## 3. NULL-stop depends on flat 32-bit addressing

The chain walk terminates on `dist = cur - cand >=
0x10000`.  An empty bucket yields `cand = 0` -> dist = cur.
This only stops the walk because a real Amiga input buffer
always sits above address 0x10000.  On a hypothetical
allocation in the lowest 64 KB (or a NULL-ish arena) the
walk would dereference address 3+.

## 4. Encoder bound is out+inlen, checked post-write

`xsp_OutBufLen` is ignored entirely; the expansion guard
is `a6 < out + inlen`, evaluated AFTER the item's bytes
were already written (1-3 bytes past the bound possible
before the -17 bail).  `xsp_OutLen` is left 0 on the -17
path... actually it is never touched on that path at all,
so callers see a stale value.

## 5. Decoder has no bound checks and never writes OutLen

`XpksUnpackChunk` trusts the flag stream completely --
no input limit, no output limit, and `xsp_OutLen` is
never assigned.  A malformed stream runs off both ends.

## 6. Inlen-0 edge case reads one byte of garbage

With `xsp_InLen = 0` the loop takes the `remaining < 4`
literal path: `a2 = inbuf-1 + 1 = inbuf`, emits inbuf[0]
(uninitialised/OOB byte) as a literal, then terminates.
A zero-length pack produces a 6-byte stream that decodes
to one garbage byte.

## 7. "cremation" is the real mode description

The `xm_Description[10]` inline field literally contains
"cremation" -- the same dead string that V3.3 left
unreferenced.  Here it is live: xpkQueryMode users see a
mode described as "cremation" for the "LZ-Welsh" codec.

## 8. xi_MaxPkInChunk = 0x7fffffff advertises nonsense

The encoder's own bound (out < out+inlen) plus its 64 KB
chain window make multi-GB single chunks meaningless;
0x7fffffff is a marketing value, shared with V3.3.
