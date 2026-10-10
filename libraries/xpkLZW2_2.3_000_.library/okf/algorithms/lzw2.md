# The LZ-Welsh algorithm (V2.3)

An LZ77 variant -- despite the 'LZW2' id it has nothing to
do with LZW.  The name is a joke: "LZ-Welsh (not Welch)".

## Workmem

327,684 bytes, allocated lazily at the first pack:

- `hash[16384]` at sub+0x00000: head-of-chain pointers,
  14-bit index `(w(p) ^ w(p+2)) & 0x3fff` where w() are
  big-endian 16-bit words -- i.e. the 4-byte window
  (b0<<8|b1) ^ (b2<<8|b3).
- `chain[65536]` at sub+0x10000: one link per position,
  indexed by the position pointer's low 16 bits -- a
  modulo-64K ring covering the advertised "64 KB window".
  Both tables store RAW POINTERS, so chain distances are
  naturally bounded to < 0x10000 by the emit gate.
- `sub-4`: the AllocMem size word (hand-rolled allocator
  header).

## Encoding

Greedy longest-match over the hash chain:

- min match 4 (tokens encode len-4), max 259;
- max distance 0xffff (the 64 KB window);
- lazy insertion -- after a match of length L only
  cur+1, cur+2, cur+3 and cur+L are hashed.  Positions
  inside the match body are skipped entirely, trading
  compression for speed;
- the quick-check `cur[best] == cand[best]` prunes chain
  entries that cannot improve on the current best before
  the (expensive) byte-by-byte verify+extend;
- ties go to the NEAREST candidate (`len >= best` accepts
  on equality while walking most-recent-first).

## Stream format

```
[flaglong:4][item x32] ... [flaglong:4][item xN][0x0000]
```

- flag long: big-endian, LSB = first item; 1 = match,
  0 = literal.  An all-zero flag long is the decoder's
  32-literal fast path.
- literal: one raw byte.
- match: `[-dist:u16be][len-4:u8]`, dist 1..0xffff,
  len 4..259.
- terminator: a set flag bit followed by token word
  0x0000.

## Decoding

Bit-serial: 4-byte flag group -> 32 items.  The token word
is added to the output cursor through a register whose
upper half was seeded with `moveq #-1`, so the 16-bit
value sign-extends: `dst + (0xffff0000|tok)` = `dst - dist`.
len = token byte + 4, copied via a mod-8 dispatched
unrolled loop (`jmp pc@(base,-n*2)` into 8 `moveb`s).
Token 0 terminates.  No bounds checks anywhere.
