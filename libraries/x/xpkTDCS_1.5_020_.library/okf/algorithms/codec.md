# xpkTDCS — codec algorithm

## Workmem (0x80004 bytes, buf[0] = size for PackFree)

- `head[65536]` ULONG at sub+0 — key → latest input pos
- `chain[65536]` ULONG at sub+0x40000 — (pos & 0xffff) → previous
  pos with same key
- key = `b0<<8 | ((b1+b2) & 0xff)` — computed as `d1 = 0xffff_w(p)
  +b(p+2)`; the add.b wraps into the low byte only, and the
  0xffff high half turns the indexed access into a NEGATIVE
  offset off `sub+0x40000`, landing head[key] at sub+key*4.

## find(cur, remaining)

Unbounded chain walk: candidates = head[key], followed via
chain[cand & 0xffff] while (cur - cand) < 0x10000 (signed).
Quick rejection: byte at [best] must match before a full compare
(longword cmpm then byte tail, then extension). Returns packed
`[dist:len]`; best starts at 2 so a real match needs len > 2.
No iteration cap — this is the "slow packing" the docs mention.

## insert(cur, len)

Per position: `chain[p & 0xffff] = head[key]; head[key] = p`.
Guard `remaining < 3` is checked ONCE for the whole tail, so a
match reaching into the last two input bytes inserts them
anyway (reads ≤2 bytes past the end).

## PackChunk main loop

- flag accumulator d6, bitpos d3.w = 30, flaglong slot at out+4
- lazy budget = `xsp_Mode / 34` (modes 33/67/100 → 0/1/2): each
  round advances 1 byte and re-runs find; adopts when
  `newlen - adv > bestlen`, literalising the gap; gives up at the
  budget.
- emit (d1 = len-3):
  - `l3 <= 3 && ndist > 0xbfff` → word `(ndist<<2)|l3`, tag 01
  - `l3 <= 15 && ndist > 0xefff` → word `(ndist<<4)|l3`, tag 10
  - else word `ndist` + byte `l3`, tag 11
  (`ndist = -dist` as an unsigned word; the `> 0xbfff/0xefff`
  compares select dist ≤ 16384 / ≤ 4096)
- flag tick: bitpos -= 2; on wrap the accumulated long is stored
  at flagslot and a new slot is taken.
- terminator: `flagacc |= 3 << bitpos` (flag 11) + zero word.
- output bound = inlen; overflow → return -17.
- outlen IS written back (xsp_OutLen) — unlike LZW5's decoder
  note; the packer itself does `out - outbuf` into xsp+16.

## PackReset

`a6 = sub+0x40000`, pushes 3 + 14 + (14 × 4) × 1260 = 70,577
zero longs DOWNWARD: clears all of head[] then continues
20,164 bytes BELOW the allocation. Chain is never cleared.

## UnpackChunk

flag long 0 → copy 16 longs literally; else 16 items:
- 00 → literal byte
- 01 → tok word; dist = asr(tok,2), len = (tok&3)+3 (3..6)
- 1x → flag bit tested BEFORE reading the word:
  - 10 → tok word; dist = asr(tok,4), len = (tok&15)+3 (3..18;
    field 0 gives len 3 via a shared 3-copy tail)
  - 11 → tok word (zero → terminate); dist = tok, len = byte+3
- dists are negative (token sign-filled from moveq #-1), copies
  run backwards from dst+dist. No outlen writeback.
