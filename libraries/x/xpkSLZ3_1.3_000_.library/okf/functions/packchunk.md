# XpksPackChunk (-36, @0x186)

Greedy LZSS encoder.  Lazily allocates workmem
(0x44004 = 4-byte size + 256 KB hash + 16 KB chain) via
`AllocMem(-198)`, returns -7 on failure, then calls
XpksPackReset.

## Registers

- `a2` = input cursor, `d7` = remaining input,
  `a6` = output cursor, `a4` = outbuf + inlen (output bound
  -- `xsp_OutBufLen` ignored, like xpkFRLE 1.2),
  `a3` = in-stream flag slot, `d6` = flag shift register,
  `a5` = chain-table base (sub+0x40000).

## Hash seed (per position, 0x1ec-0x212)

```
d1 = 0xffffffff                     ; moveq #-1 trick
d1.b = p[0]; d1 <<= 8; d1.b = p[1]; d1.b += p[2]
d1 <<= 2                            ; = hash*4 - 0x40000 (signed)
d0 = a5[d1]                         ; hash[hash]  -> prev pos
a5[d1] = p                          ; hash[hash]  = pos
chain[p & 0xfff] = d0               ; ring insert
```

The `(0xffff0000|h)<<2` sign-extension means indexing a5
(sub+0x40000) lands at `sub + h*4` -- one base register
serves both the 256 KB hash at sub and the 16 KB chain
ring at sub+0x40000.  Reads p[1]/p[2] unconditionally:
up to 2 bytes OOB on the final positions.

## Candidate walk (0x216-0x292)

- `dist = cur - cand`; if `dist > 0xfff` -> done.
- Quick check `cur[best] == cand[best]` (byte AT the best
  length -- rejects candidates that cannot beat `best`).
- Full compare: up to 16 `cmpm` pairs, bytes 1..16 (byte 0
  implied by the shared hash); clamp len to `remaining`.
- If `len >= best`: best=len, remember [dist:len] in d5;
  `len >= 17` -> emit immediately (greedy).
- Else follow `cand = chain[cand & 0xfff]` (ring links).

On chain exhaustion: emit match iff `best >= 3`, using the
BEST pair's distance -- a subtle detail: d5 carries
[dist:len], not the chain-end pointer.

## Emit

- Match: `[dist_hi4 | len-2][dist_lo8]` + flag bit 1.
- Literal: raw byte + flag bit 0.
- Flag sentinel: d6 starts at 1; each item adds a bit;
  carry-out -> store flag at the saved slot, reserve the
  next slot at the current output position.
- Output bound `cmpal a4,a6` AFTER each item -> up to a
  2-byte overrun before the -17 error.

## Stream end

`orib #16; addxb` pads with one 1-bit then `addb` 0-bits
until the flag flushes; `clrb a6@+` writes the 0 terminator.
The leading 1-bit makes the decoder take a match branch onto
the terminator byte.
