# mathffp.library 36.5 — vector map

Word-offset functab at hunk0+0xf8 (marker `ffff`, signed word
offsets from table base, `-1` terminator).

| LVO | name     | target | notes |
|-----|----------|--------|-------|
| -6  | Open     | 0x0d0  | DELEXP set → return -1; else opencnt++, return base |
| -12 | Close    | 0x0e4  | opencnt--; last close does NOT expunge (quirk) |
| -18 | Expunge  | 0x092  | unlinks node + FreeMem(base-negsize,total) |
| -24 | ExtFunc  | 0x0f6  | bare `rts`, shares InitFunction; returns garbage d0 |
| -30 | SPFix    | 0x11c  | FFP→LONG, truncation; saturation ±2^31 with V set |
| -36 | SPFlt    | 0x170  | LONG→FFP; -2^31 handled via neg.l V path |
| -42 | SPCmp    | 0x1a8  | compare r-l; result ±1/0, CCR = real cmp flags (via GetCC -528) |
| -48 | SPTst    | 0x1e4  | sign of d1 byte; ±1/0, CCR restored |
| -54 | SPAbs    | 0x20c  | `and.b #0x7f` — no denormal check at all |
| -60 | SPNeg    | 0x212  | `tst.b/beq/eori.b#0x80` — denormal returned UNCHANGED |
| -66 | SPAdd    | 0x236  | shared add/sub machine, d1-d0 same-sign paths |
| -72 | SPSub    | 0x21c  | entry flips A sign then joins add machine; computes d0-d1 |
| -78 | SPMul    | 0x32c  | exp-sum in doubled-byte domain, 24×24→48 partial products |
| -84 | SPDiv    | 0x3f4  | two-step divu/mulu divide + borrow correction |
| -90 | SPFloor  | 0x47a  | positive: mask frac bits; negative: -(floor(|x|)+[frac≠0]) |
| -96 | SPCeil   | 0x470  | `bsr SPNeg; bsr SPFloor; bra SPNeg` |

## Entry dispatch (add/sub machine)

```
SPSub: d4 = d1.b; if 0 → ret d0.  d4 ^= 0x80.
       d4 bit7 set → 2b0 dispatch; else:
         d0.b sign → 2b6 (mag sub); d0.b≠0 → 246 (mag add); 0 → 280 (ret A)
SPAdd: d4 = d1.b;  sign set → 2b0; 0 → ret d0.
         d0.b sign → 2b6; d0.b=0 → 280; else 246
2b0:   d0.b sign → 246; =0 → 280; else 2b6
246:   magnitude add (align smaller mantissa, +0x80 round seed)
2b6:   magnitude subtract (equal-exp → L318 direct subtract+norm)
280:   return A operand with effective byte d4
28a:   return B (d0) as-is
```

The exponent compare uses `^0x80`-biased bytes so sign and
magnitude fold into one byte; the doubled-exponent trick
(`add.w` then `eor.b #0x80`) puts the operand sign into bit 8
so `ror.w #1` folds `sA^sB` into the result byte's bit 7.

## Divide algorithm (SPDiv)

1. divisor byte 0 → `divu.w #0` hardware trap (re-entered
   forever if the trap handler returns; exact 0 → saturate
   0xffffff7f|sB +V).
2. exponent subtract in doubled domain; overflow → ret 0 or
   saturate (0x3e2 path merges the DIVISOR's byte — sign is the
   divisor's sign, a quirk).
3. `cmp.w` on swapped regs compares mantissa hi16 **signed**;
   if mN_hi ≥ mD_hi: exp += 2 (doubled) and `ror.l #1` the
   dividend.
4. `divu.w` quotient q1; mulu back-subtract for remainder;
   remainder<<16 minus `q1 * mD_lsb<<8`; borrow → `q1--,
   rem += divisor` loop (adds the FULL divisor including its
   exponent byte — the loop's carry-out termination makes this
   harmless).
5. second `divu.w` on `rem<<16` → q2; merge `[q1][q2]`,
   doubled if q1<0x8000 (exp--); +0x80 round; merge byte.

## Multiply algorithm (SPMul)

1. either byte 0 → return B operand as-is / ret 0.
2. doubled-byte exponent sum; V → saturate `0xffffff7f|(sA^sB<<7)`
   (+V) or 0 depending on wrapped N flag.
3. 24×24 mantissa product via three 16×16 mulu partial sums;
   the `addx.b` step propagates the cross-add carry at bit 16 —
   equivalent to keeping the top 32 bits of the 48-bit product.
4. top bit set → +0x80 round, merge byte. Else exp-1 path:
   `resb∈{0x80,0x00}` → 0; else `d0 += 0x40; d0 <<= 1`,
   carry → `roxr` + exp++.
