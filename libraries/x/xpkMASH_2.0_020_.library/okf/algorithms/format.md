# MASH 2.0 stream format & matcher

Bit-packed LZ77, 32KB window, MSB-first bits.  The "2 mixed
streams": flag bits and literal bytes share one output
cursor — the emitter reserves a byte slot when a pending
bit-group starts and backfills it when 8 bits accumulate.

## Token grammar (decoder's view)

```
while out < outend:
  literal run:
     '0'              -> 0 literals
     '1'^n '0'        -> n literals (n=1..5)
     '1'^6 '1'^k '0' + bcc-gamma -> run = rclass[1+k].base + g + 6
     copy `run` raw bytes
  match (always follows):
     '00' + 9-bit dist                -> len 2
     '01' + 3-bit class + bcs-gamma   -> len 3
     '1' + '1'^k '0' + bcc-gamma      -> len-2 = lclass[k].base + g
        then 3-bit class + bcs-gamma -> dist
  copy `len` bytes from out-dist
```

**bcc-gamma** (run/len tables): a seed word is shifted left
through the bit accumulator; consume one bit per shift until
the bit that fell out of bit 15 was set — the shifted word
is the excess value; add the table base.  Seed `1<< (15-w)`
gives a `w`-bit field headed by `w` leading zeroes, i.e. a
plain gamma.

**bcs-gamma** (distance): same but shifts while the bit
falling out is *set* — i.e. leading-ones + payload, seeded
from the class table; add the class base.

Accumulator detail: when the bit acc runs dry mid-field and
`d4 >= 0xff00`, the decoder grabs a whole input byte into
d4 (8 bits at once) before the acc reload — bit-equivalent
to 8 sequential reads, but see the flag-byte defect in
findings.

## Tables (verbatim from the binary)

- `runw` @0x496: run 0..7 = `{0000,8001,c002,e003,f004,
  f805,fc07,fd07}` (code<<8|nbits-1); >=8 uses emit_gamma
  (gap-8, bits4..10)
- `lenw` @0x476: len-2 0..15 = `{0001,4001,8002,a002,c004,
  c804,d004,d804,e006,e206,e406,e606,e806,ea06,ec06,ee06}`
- `dclass` @0x638 `{base, seed}`:
  `{0,f000},{20,fc00},{a0,ff00},{2a0,ff80},{6a0,ffc0},
   {ea0,ffe0},{1ea0,fff0},{3ea0,fff8}` — 8 classes,
  3-bit selector + gamma, max dist 32415 (0x7e9f)
- `lclass` @0x658 `{seed, base}`: seed `8000>>k`,
  base `1<<(k+1)` for k=0..14 (len-2 = base + excess);
  entry 15 overlays the rclass header
- `rclass` @0x690 `{seed, base}`: base `2<<k - 2`... i.e.
  0,2,6,e,1e,3e,7e,fe,1fe,3fe,7fe,ffe,1ffe,3ffe,7ffe,fffe;
  run = base + gamma + 6 (the +6 = 1 dbf copy + 5
  fall-through byte copies in the unrolled literal loop)
- pack-side `distw` @0x436 `{bits, span}`:
  `{8,20},{10,80},{12,200},{13,400},{14,800},{15,1000},
   {16,2000},{17,4000}`; `distor` @0x456 =
  class<< (bits-3): `{0,80,400,c00,2000,5000,c000,1c000}`

## Pass 1 — gap array (0x26e)

Rolling 16-bit key: `d1 = (d1<<8 | *in++) & 0xffff`
starting from the first byte; `head[d1]` (UWORD table at
wk+0, cleared to 0) holds the previous 1-based position of
the pair.  For each index: `gap = prev ? pos - prev : -1`,
`head[key] = pos`.  Writes `pairs = inlen>>1` longs (2 gap
words per loop); reads `1 + 2*pairs` bytes — one byte PAST
InBuf when inlen is even (defect).  For pairs >= 16203 the
second phase clamps `gap >= 32415 -> -1`.  Tail:
`gaps[inlen-1] = -1` sentinel.

## Pass 2 — lazy matcher (0x320)

Walks positions; a1 is a BYTE cursor into gaps (hops are
2*gap bytes — odd/negative gaps hop ~64K into garbage,
faithful).  Per position: follow the gap chain up to
`tries`=1024 candidates; for each candidate `cmpmb`
compare (UNBOUNDED — scans past InBuf into memory until a
differing byte; see defects); lazy: if a later position
beats the current best by enough, drop to literal.  Best
match -> record `{pos.w, dist.w, len-2.w}` at the head
table; len-2 matches with dist >= 512 are dropped to
literals (two checks).  Records eventually overwrite the
live gap table for large inputs (defect).

## Pass 3 — emit (0x4ce helpers + loop)

Per record: `emit_run(litgap)`, then the match code
('00'+9bit dist for len-2, '01' for len-3, else '1'+gamma
len), `emit_dist` (class<<bits-3 | dist-base, MSB-first,
bits-1 count).  After the last record: trailing literal
run + end marker.  The final partially-filled flag-slot
byte is never written -> last output byte is heap garbage
(defect).  Bound check: if the record write or the emit
cursor passes `OutBuf + InLen - 10` the pack aborts -17
(mid-record records are checked, so a small input that
grows emits a full stream then still fails).
