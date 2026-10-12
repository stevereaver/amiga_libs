# Vector map — xpkMASH 1.26 (functab = LONG offsets rel. lib base)

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
exg d0,a5 ; move.l a6,34(a5)   ; exec base
move.l a0,38(a5)   ; seglist
exg d0,a5 ; rts
```

## PackChunk (@0x124)

1. AllocMem 0x10000 (flag 1) = alloc1 — fail -> **-7**.
   alloc1 = chain table (`alloc1+0x8000` base, entry `sext16(pw)*2`,
   UWORD deltas).  **Not initialised** except `chain[in.w] = 0xffff`.
2. alloc2 ("Dynamic Buffer Allocation"): AllocMem 0x20000 flag 1,
   retry counter d5 = 5: failures halve the size and decrement d5 —
   sizes 0x20000,0x10000,0x8000,0x4000,0x2000 — all fail -> free alloc1,
   **-7**.  On success `shift = d5+3` (8..4); alloc2 = `512<<shift`
   bytes = hash head table (`256<<shift` UWORDs), `filldown` seeds all
   heads with `in.w` (and underwrites the allocation by 0x100).
3. `bound = outbuf + inlen - 10` written back to `xsp+0x3c`;
   `tries = 1 << (xsp_Mode/10)` to `xsp+0x40`.
4. Pack core: loop from in+1; `find` inserts cur then walks the chain
   bound by `cur-32415` and the `tries` rejection budget; first
   candidate compared unconditionally, later candidates only when
   `cand[len] == filt`; `cmpm` compare capped at 522 bytes; lazy
   one-step lookahead prefers strictly-better next matches.
   len-2/dist>=512 matches are dropped by the `addi.l #0xfe000000`
   carry trick (see defects).
5. Emit: run code + raw literal bytes, then match token — len2
   `00`+dist9b RAW (dist<512 enforced by the finder); len3 `01`+class+
   dist; len>=4 `1`+unary+lclass excess + 3-bit dist class + payload
   (5/7/9/10/11/12/13/14-bit payloads at bases
   0,0x20,0xa0,0x2a0,0x6a0,0xea0,0x1ea0,0x3ea0).
   Bit emitter: sentinel slot accumulator, MSB-first — plus the 1.26
   whole-byte fast path: after a slot byte stores, if >=8 field bits
   remain the next byte is written raw (`rol.l #8` / `move.b d0,(a1)+`).
   `epos >= bound` before each run/match emit -> abort -> **-17**.
6. Flush sentinel; `xsp_OutLen@0x10 = epos-outbuf`; FreeMem both;
   return 0.

## UnpackChunk (@0x1ca)

Bit accumulator with sentinel reload (`add.b d3,d3` / `addx.b`);
token order per unit: literal-run prefix then a match, always.
- run: `0`=0, `10`..`11110`=1..5, `11111`+unary w+counted excess,
  run = rclass[w].base + excess + 6 — copies raw bytes inline.
- match: `00`+9-bit dist = len2; `01`+3-bit class+payload = len3;
  `1`+unary w + (w+1)-bit excess = len `lclass[w].base+excess+2`,
  then 3-bit dist class + payload; copies `out-dist..` len+1 bytes
  (dbf + fallthrough).
- payload loops have the 1.26 byte-load fast path: when the bit acc
  is empty AND the payload sentinel's top byte is all ones
  (`cmp.w #0xff00`), `lsl.w #8` / `move.b (a0)+,d4` swallows a whole
  input byte — semantically identical to bit-by-bit reads.
- outer loop `cmp.l a1,d0; bhi` — ends when `outend <= out`.
