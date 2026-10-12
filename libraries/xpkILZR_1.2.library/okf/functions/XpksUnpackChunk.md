---
type: Function
title: XpksUnpackChunk (LVO -54)
---

# XpksUnpackChunk — xpkILZR 1.2

`a0 = xsp`, `a6 = libbase`.

1. `d7 = in.w` (declared outlen), `a2 = in+2`
2. `d7 > xsp_OutBufLen` → `-10` (compares the CALLER's
   buffer length at +0x0c)
3. **`xsp_OutBufLen = d7`** — overwrites +0x0c with the
   declared length
4. `a4 = out+256`, `d5 = 8` (pos width), `d4 = 0` (bit idx)
5. loop while `d7 > 0`:
   - flag bit `a2[0] & (0x80>>d4)`; `d4++`
   - literal: byte-align `d4` (`if d4>7: a2++,d4=0`), then
     `*a3++ = RD32(a2) >> (24-d4)`, `a2++`, `d7--`
   - match: byte-align; `if a3 > a4: d5++, a4 = base+2^d5`;
     `pos = RD32(a2) >> (32-d5-d4) & (2^d5-1)`;
     advance `d4 += d5`, `a2 += d4>>3` manually;
     `len = (RD32(a2) >> (28-d4)) & 15 + 3`;
     copy `len` bytes from `out+pos` — ABSOLUTE index
6. no production bound — a terminal oversized match runs
   past the declared length (shipped)

Return 0 / -10.
