# findings / defects

## 1. PackReset clobbers ~90 KB below the allocation (severe)

The shipped fill writes `3 + 14 + 14*4*1260 = 70,577` longs
(282,308 bytes) DOWNWARD from `sub+0x40000` with pre-decrement
movem stores.  It clears the whole 64K-long head table and then
keeps going 20,164 bytes past `sub+0` -- i.e. 20,160 bytes below
the start of the 0x80004 AllocMem block, into whatever lives
underneath in the heap.

The chain ring at sub+0x40000..0x7ffff is never initialised
(stale entries are harmless because the >=64KB distance bound
kills garbage candidates), but the underflow is a real write
overrun: every XpksPackChunk call -- PackReset is invoked inside
the packer, not just from the API -- smashes ~20 KB of other
allocations.  On a real system this is fatal.  Reproduced
faithfully in the C (the reconstruction writes the same range;
the host harness pads the arena to observe it safely).

(For comparison, LZW3 3.3 underflowed its fill by 68 bytes; LZW4
4.3 fixed it to exactly 65,536 longs; 5.3's regression is the
largest of the family.)

## 2. Short/medium tier bounds emit self-corrupting tokens (shipped)

The tier tests compare the raw emitted distance word unsigned:
`cmpi.w #$bfff,d0 / bls` picks short when `ndist > 0xbfff`
(dist <= 16384) and `cmpi.w #$efff,d0 / bls` picks medium when
`ndist > 0xefff` (dist <= 4096).  But the packed fields only hold
14/12 bits of distance:

- SHORT `(-dist)<<2 | (len-2)`: for dist in 8192..16383 the shift
  drops the sign bit; the decoder reads `asr` on a POSITIVE token
  and copies FORWARD from unwritten output.  Worst case
  dist = 16384 -> token = len field only (tok < 4).
- MEDIUM `(-dist)<<4 | (len-2)`: dist = 4096 -> tok = field only;
  dist 4096+ was already excluded, so only exactly 4096 is broken.
- LONG is the only safe tier for dist >= 8192.

The streams stay byte-synchronised (the flag/length accounting is
fine), so decoding "succeeds" while producing wrong output --
silent corruption for any len-3..5 match at distance 8192-16383
or a len-6..17 match at exactly 4096.  Roughly a third of our
3000-trial corpus hits this path.  Reproduced verbatim -- the C
emits the identical corrupt tokens as the shipped binary.

## 3. Tail overreads (shipped)

- insert() checks `remaining >= 3` once then chains all `len`
  positions of the emitted item; at the tail this reads up to
  ~260 bytes past the input buffer (len up to 258 + 2 key bytes).
- the lazy probe loop decrements `remaining` per probe without a
  lower guard; with budget >= 2 it can wrap the count negative
  and hash/search past the end (same family defect as LZW4).

## 4. Decoder is fully unchecked (shipped)

No bounds checks on src or dst.  Beyond the tier defect, a zero
len byte in a LONG token still produces len 3 via the jump-table
entry point; distances always reach backward by construction
(the `moveq #-1` seeding), so a corrupt stream cannot underflow
dst below its start but walks it arbitrarily far forward.

## 5. 68020 gate

LibInit fails on plain 68000/68010 (returns d0=0 through the
shared null stub) -- the (020) build is unusable on base systems;
presumably a parallel 68000 build existed.
