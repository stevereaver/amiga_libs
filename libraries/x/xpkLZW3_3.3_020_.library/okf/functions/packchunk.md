# XpksPackChunk (-36, @0x194)

Greedy LZ encoder (FastLZ-family, like xpkSLZ3 but 020+).

## Workmem (0x80004 bytes, lazily AllocMem'd)

    buf[0]       ULONG  allocation size (for PackFree)
    sub+0x00000  ULONG  hash[65536]  - last pos per hash
    sub+0x40000  ULONG  chain[65536] - ring, pos & 0xffff

## Registers

a3 = flag-long slot, a6 = output cursor (starts outbuf+4),
d6 = flag accumulator, d3 = item count 0..31,
a2 = input cursor, d7 = remaining, a5 = hash base,
a4 = chain base (sub+0x40000), d4 = outbuf + inlen (bound --
xsp_OutBufLen ignored, like xpkFRLE 1.2 / xpkSLZ3).

## Hash seed (per consumed position)

    h = w(cur) ^ w(cur+2)              4-byte window
    cand = hash[h]; hash[h] = cur
    chain[cur & 0xffff] = cand

Only run while remaining >= 4 -- tail bytes go literal, so
the seed never reads out of bounds (unlike xpkSLZ3).

## Candidate walk

dist = cur - cand; stop when dist >= 0x10000 (64KB window).
Quick check `cur[best] == cand[best]` prunes candidates that
cannot reach `best`; then verify bytes 0..best-1 (as
cmpml longs + cmpmb tail) and extend toward
`maxlen = min(259, remaining)`.  `len >= best` wins (later
walk candidates win ties -> farthest distance retained);
break at maxlen.  The best pair is carried PACKED as
[dist:len] in one register (swap d2) so the emit is:

    d0 = d5; swap; negw -> word = -dist
    movew d0,a6@+       -> [-dist:u16]
    moveb (len-4),a6@+  -> [len-4:u8]

Literal: raw byte + best=1.

## Flag groups

d3 counts items 0..31; a match sets bit d3 of d6.
At 32: `movel d6,a3@` stores the group big-endian, a new
4-byte slot is reserved at the current position.  LSB of
the stored long describes the first item.  A group of all
zeros = 32 literals (decoder fast path).

## End

`bset d3,d6; movel d6,a3@` sets a match bit (so the decoder
reads a token), stores the flag, then `clrw a6@+` writes the
0 token word.  xsp_OutLen = a6 - outbuf; return 0.

## Bound check

`cmpal d4,a6` after every item -> -17 on expansion,
checked AFTER the write (small overrun possible).
