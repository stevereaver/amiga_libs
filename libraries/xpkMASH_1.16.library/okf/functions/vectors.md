# Vector map — xpkMASH 1.16 (functab = LONG offsets rel. lib base)

10 entries + `0xffffffff` terminator.

| LVO | function |
|-----|----------|
| -6  | Open: `opencnt@32++`, `bclr #3,flags@14`, d0=a6 |
| -12 | Close: `opencnt--`; if 0 && bit3 set -> Expunge |
| -18 | Expunge: if opencnt -> `bset #3,flags`, d0=0; else Remove@-252, FreeMem(lib-negsz, negsz+possz)@-210, d0=seglist@38 |
| -24 | `moveq #0,d0; rts` |
| -30 | XpksPackerInfo: `exg a0,d0` around `lea` -> d0=desc, a0 preserved |
| -36 | XpksPackChunk (a0 = XpkSubParams) |
| -42 | `moveq #0,d0; rts` |
| -48 | `moveq #0,d0; rts` |
| -54 | XpksUnpackChunk (a0 = XpkSubParams) |
| -60 | `moveq #0,d0; rts` |

Unsupported vectors return 0, not -17 (they are plain stubs).

## LibInit

```
movem.l a5,-(sp); movea.l d0,a5
move.l  a6,34(a5)   ; exec base (NOT seglist)
move.l  a0,38(a5)   ; seglist
movea.l (sp)+,a5; rts
```

68000-safe; returns d0=libbase.

## PackChunk (@0x366)

1. `bound = outbuf + inlen - 50` — output must stay 50 bytes under the
   input size or the pack fails with **-17** ("not compressible").
2. `tries = 1 << (mode/10)` from `xsp_Mode` (+0x1c).
3. AllocMem 0x10000 (flag 0) into `Sub+0` — fail -> **-7**.  This buffer
   holds the 0x8000-entry chain table (UWORD deltas) **plus** the hash
   heads at `buf + 0x10000 - (2<<shift)` — the head table shares the
   tail of the same allocation.
4. Second allocation starting at 0x20000, halving until <= 0x3000 —
   "Dynamic Buffer Allocation": `alloc2 -> 0x20000,0x10000,...,0x4000`,
   `shift = log2(alloc2>>1)` (d3 = d1-1 where 2^d1 = alloc2).  Fail ->
   free alloc1, return **-7**.  `Sub+1` = alloc2, used as the *chain
   table*; alloc1 is the hash head table.  `memset` clears `alloc2+0x100`
   bytes of `alloc1` (see defects).
5. Loop from in+1: `insert(cur)` (hash + store delta into chain), then
   `find(cur)`: walk `chain` back from `head[h]`, bound by `cur-0x8000`
   (32KB window) and by `tries` *filter rejections*; the first
   candidate is always compared (unconditional best), later candidates
   only if `cand[len] == filt` (the byte that ended the last best
   compare — a cheap "does the match get longer" heuristic).
   Compare is `cmpm` up to 522 bytes (d0=521, dbne), capped at
   `inend-1`; the predecrement `moveb a4@-,d5` both records the new
   filter byte and fixes the off-by-one (a4 lands on the mismatching
   byte).
6. Lazy eval: the match at `cur` is emitted only if `find(cur+1)` is
   not strictly better; otherwise cur advances by one literal.
7. Token emit (bit codes MSB-first, literal bytes through the same
   output pointer):
   - run code then raw literal bytes; run = `0`(+0) or
     `1`+unary-ish code `0|10|110|1110|11110`(r=1..5) or `11111`+
     unary class + excess (r>=6)
   - match: len2 `00`+dist9b RAW (see defects); len3 `01`+class+dist;
     len>=4 `1`+unary+lclass excess + 3-bit dist class + payload
     (classes `000..111` + 5/7/9/10/11/12/13/14-bit payloads at bases
     0,0x20,0xa0,0x2a0,0x6a0,0xea0,0x1ea0,0x3ea0)
   - After a match, `len` positions are inserted into the hash.
8. Bit accumulator: sentinel-based (`lsr` by clz, `x` flag refill).
   Bound check `epos >= bound` before each run/match emit -> **-17**.
9. On end: flush sentinel byte; `xsp_OutLen@0x10 = epos-outbuf`;
   FreeMem allocs, return 0.

## UnpackChunk (@0x5ea region)

Byte-precise bit reader: `acc` = 8-bit window MSB-first; sentinel bit
marks refill.  Per iteration:

- `0` -> match-only (run of 0); `1` -> literal-run code (the same
  table as the packer), copy `run` bytes raw, then **unconditionally**
  parse a match token.
- match: `00`->len2+9b dist; `01`->len3+3b class+payload;
  `1`->unary+lclass excess (len>=4)+3b class+payload;
  `copy dist` bytes from `out-dist`.
- `while (out < outend)`; returns 0 on completion (garbage-tail safe
  only by luck — see defects).
