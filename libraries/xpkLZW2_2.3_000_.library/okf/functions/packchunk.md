# XpksPackChunk (@0x186) -- encoder

## Prologue

- If `xsp_Sub[0]` == 0: AllocMem(0x50004, 0) -> -7 on
  failure; `buf[0] = size`; `xsp_Sub[0] = buf + 4`.
- Calls PackReset (zeroes the hash region -- and 5,040
  bytes below it, see findings).
- `a5 = sub` (hash), `a4 = sub + 0x10000` (chain ring).
- Output cursor a6 = OutBuf+4 (first flag-long slot at
  OutBuf+0, tracked in a3); bound d4 = OutBuf + InLen.
- a2 = InBuf - 1, d7 = InLen remaining, d5 = prev item len
  (seeded 1), d3 = flag bit counter, d6 = flag register.

## Seed step (lazy insertion)

At loop top, after `cmpil #4,d7` (fewer than 4 remaining
bytes -> literal path via `a2 += d5`):

- `d5--`; if the result is nonzero (previous item was a
  match of length L): `d2 = -3; d5 -= 3` (d5 = L-4).
- Inner seed loop: `a2++`; hash the 4-byte window
  `h = ((a2[0]<<8|a2[1]) ^ (a2[2]<<8|a2[3])) & 0x3fff`;
  `cand = a5[h]`; `a5[h] = a2`; `a4[a2&0xffff] = cand`;
  `d2++` until d2 >= 0.
  - For a literal (d5 was 1 -> 0): d2 stays 0 -> exactly
    ONE insert at cur+1.
  - For a match (d2 starts -3): THREE inserts at
    cur+1..cur+3, then `a2 += d5` (skip L-4 positions) and
    ONE more insert at cur+L -- the new cursor.  Positions
    inside the match body are never hashed.
- When L < 4 impossible -- emit gate requires len >= 4.

## Match search

- `d5 = 3` (best len); `d1 = min(259, remaining)`.
- Chain walk: `d2 = a2 - cand`; if >= 0x10000 stop
  (the NULL-stop trick: an empty bucket is 0 -> dist =
  cur -> huge -> chain ends).
- Quick-check: `a2[d5] == cand[d5]` (the byte AT the
  current best length -- only candidates that could beat
  the best get verified).  Then `cmpmb` verifies the first
  d5 bytes, then `cmpmb` extends toward d1.
- `negw d2; addw d1,d2; subqw #1` reconstructs the total
  length; `cmpw d5,d2; blss` keeps the old best on strictly
  shorter; `movel d2,d5` installs the new best as
  [dist:len] (d2's high word still carries the swapped
  distance!).  `cmpw d1,d5; bccs` emits immediately at
  len >= maxlen.
- Next candidate: `cand = a4[cand & 0xffff]`.
- Chain end: `cmpiw #4,d5; bcc` -> match emit, else literal.

## Emit

- literal: `moveb a2@,a6@+` (1 byte, no flag bit).
- match: `d0 = d5; swap; negw` -> low word = -dist; emit
  two bytes [-dist] then one byte [len-4]; `bset d3,d6`.
- after each item: `d3++`; if d3 == 32 flush `d6` BE to
  a3, `a3 = a6; a6 += 4`, d3 = d6 = 0.
- bound: `cmpal d4,a6; bcc -> -17` (a6 must stay below
  out+inlen; expansion guard, checked AFTER the write).
- `d7 -= d5; bgt loop`.

## Terminator

`bset d3,d6` (forces a nonzero group), flush BE to a3,
`clrb a6@+` x2 (the 0x0000 token word).  OutLen =
a6 - OutBuf; return 0.

## XpksPackFree (@0x112)

`d0 = xsp_Sub[0]`; if 0 return.  `a1 = d0 - 4`;
`d0 = *(a1)` (the size word); `jsr a6@(-210)` FreeMem;
return 0.  Reads the size from the long BEFORE sub -- so
a zeroed size word (PackReset underflow) frees nothing.

## XpksPackReset (@0x12a)

If `xsp_Sub[0]` == 0 return.  `a6 = sub + 0x10000`; zeroes
d1-d7/a0-a5, then writes one `movem d1-d4,a6@-` frame
(16 bytes) and 252 iterations of five `movem d1-a5,a6@-`
frames (280 bytes each) = 16 + 70,560 = 70,576 bytes
DOWNWARD.  Intended: the 65,536-byte hash table.  Actual:
5,040 bytes below `sub` -- including the size word at
sub-4 and ~5 KB of foreign heap.  See findings.
