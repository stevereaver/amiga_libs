# algorithms

## Hash-chain LZ with tiered tokens
- key(p) = `src[p]<<8 | ((src[p+1]+src[p+2])&0xff)` -- 16-bit key;
  the third byte adds into the low byte only (move.w + add.b)
- head[key] = newest inserted position (absolute pointer)
- chain[pos & 0xffff] = previous position with same key
- match walk: while `(LONG)(cur - cand) < 0x10000` (signed bound,
  so stale/garbage candidates die immediately); quick-check the
  byte at [best] first, verify 0..best-1 in CMPM.L 4-byte blocks
  plus the `best&3` tail, then CMPM.B-extend to min(258, rem)
- best match carried packed as `(dist<<16)|len`; emit does
  `swap`+`negw` so the stored word IS the negated distance
- lazy: budget = mode/34 probes ahead; adopt when
  `nlen - adv > best` (signed word compare); rewind, emit the
  gap as literals (each inserted + flag-ticked), continue until
  budget exhausted or len 258
- flag long: 16 x 2-bit items, MSB first; literal ors nothing;
  match ors `tag<<bitpos`; bitpos -= 2/item, flush when <0
  (write acc to the reserved slot, reserve the next 4 bytes)
- terminator: `bset bitpos,acc` (flag 01) + zero word
- decoder mirrors the tiers; jump-table unrolled copies

## Family differences vs LZW4 4.3
| item | LZW4 | LZW5 |
|------|------|------|
| flag bits/item | 1 (32/long) | 2 (16/long) |
| token | [-dist:16][len-3:8] | tiered 14/12/16-bit dist |
| len range | 3..258 | 3..5, 6..17, 6..258 by tier |
| lazy budget | (mode-1)/25 | mode/34 |
| modes | 4 | 3 (cremation/ashes/oblivion) |
| PackReset | exactly 65536 longs | 70577 (overruns ~20 KB) |
