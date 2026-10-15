# xpkACCA 1.2 — vector map

AUTOINIT, **word-offset** functab at hunk+0x94 (offsets relative to
functab, `ffff` marker + `ffff` terminator) — the 1.4-HFMN-style
two-pass scheme.

| LVO | target | bytes | function |
|-----|--------|-------|----------|
| -6  | 0x00b4 | `52 6e 00 20 08 6e ...` | LibOpen — `addq.w #1,OpenCnt(a6)`; `bclr #3,Flags`; `move.l a6,d0` |
| -12 | 0x00c2 | `53 6e 00 20 66 ..` | LibClose — dec OpenCnt; if 0 && DELEXP -> expunge; else ret0 stub |
| -18 | 0x00d4 | `4a 6e 00 20 66 ..` | LibExpunge — if open: `bset #3,Flags`, ret 0; else exec `Remove(-252)` + `FreeMem(-210)` of base-NegSize, NegSize+PosSize; returns seglist@+34 |
| -24 | 0x0000 | `70 00 4e 75` | Reserved — entry stub (`moveq #0,d0; rts`) |
| -30 | 0x0186 | `41 fa ..` | XpksPackerInfo — `lea pc@(xpkinfo),a0; rts` (0x678) |
| -36 | 0x018e | `48 e7 3f 3e ..` | XpksPackChunk — mode gate on xsp+28 (<=79 turbo 0x4004 / >79 crawling 0x48004); one-time AllocMem (flags=1 MEMF_PUBLIC, *uncleared*); stores size long at buf-4, xsp+52=body, xsp+56=0/15; calls PackReset; jmp core. -7 on alloc fail |
| -42 | 0x0112 | `22 68 00 34 ..` | XpksPackFree — `p=xsp+52`; if set: FreeMem(p-4, *(p-4)) — does NOT clear xsp+52 |
| -48 | 0x012a | `4a a8 00 34 ..` | XpksPackReset — downward clear, 160-byte chunks x105 per pass x(Sub1+1), descending continuously; from Sub0+0x4000 (+0x3c000 when Sub1) |
| -54 | 0x054a | `48 e7 3c 3e ..` | XpksUnpackChunk — decoder below; writes produced len at xsp+12 (the OutBufLen slot!) |
| -60 | 0x0000 | `70 00 4e 75` | XpksUnpackFree — **entry stub** (same `moveq#0;rts` as -24) |

## Routine map

| addr | role |
|------|------|
| 0x000 | entry stub `moveq #0,d0; rts` (-24/-60 target) |
| 0x018 | hunk code start; RomTag @0x04 |
| 0x064 | InitTable: dataSize 0x26, functab 0x94, datatab 0x74, init 0xac |
| 0x0ac | LibInit: `movea.l d0,a1; move.l a0,34(a1); rts` |
| 0x0b4 | Open / 0x0c2 Close / 0x0d4 Expunge |
| 0x112 | PackFree, 0x12a PackReset, 0x186 PackerInfo |
| 0x18e | PackChunk entry (mode select + alloc + reset) |
| 0x1e8 | turbo packer (`jmp`ed core, 0x1e8..0x35a) |
| 0x35c | crawling packer (0x35c..0x538) |
| 0x53a | tab16 common-byte table |
| 0x54a | UnpackChunk decoder (0x54a..0x676) |
| 0x678 | XpkInfo descriptor + mode records (0x6b4..0x723) + strings |

## Turbo packer highlights

- regs: a1 in-cursor, a3 in-end, a2 token-out cursor, a0 flag-slot,
  a4 run anchor/match cur, a5 candidate, a6 workbuf, d6 out bound
  (out+OutBufLen-48), d0 bit idx, d3 flag accum, d2 len, d4 dist-3,
  d5/d7 hash+count scratch.
- bound check only on flag-slot flush (`a2 >= d6` -> -17).
- match window: dist-3 must be `<= 4095` signed (no lower bound!);
  len cap 269; len>=2 emitted.
- emit: len 2..13 -> `(len<<4)|(distm3&15)` byte + `asr4(distm3)`;
  len>13 -> `0xf0|(distm3&15)`, `(distm3)>>4`, `len-14`.
- run path: R=3+E extras; E>15 -> class-1 (`0x10|(E&15)`,
  `(E>>4)-1`, byte); else byte==0 -> `E|0xe0`; else `E`,byte.
- pair path (no match && cur[1]==byte && byte in tab16): `0x20|i`,
  consumes 2.

## Crawling packer highlights

- regs: a2 cur(=in-1), d7 remaining, a5 heads(65536), a4 ring(8192),
  a6 byte-out, a3 flag slot, d4 bound = out+InLen, d3 bit idx,
  d6 flag accum, d5 = (dist<<16)|len packed / hops word, d0 cand.
- insert: `a2++`, h = `(b0<<8)|((b1+b2)&0xff)`, `head[h]=a2`,
  `ring[a2&0x1fff]=oldhead` — hops = low word of packed d5.
- walk: dist = a2-cand; `>=4099` exits (emit), `<3` skips;
  filter byte `cur[bestlen]==cand[bestlen]`; dbne compare bestlen-1
  bytes; dbne extension `cap-bestlen-1`; `nl = cap-rem-1`; nl>=bestlen
  -> `d5=(dist<<16)|nl`; nl>=cap -> emit early.
- run: cap 4114, then `R > bestlen` -> run emit else match emit.
  R>=18 -> class-1 with N=R-19 (**R=18 -> N=-1 defect**).
- len>=13 -> class-15 (`0xf0|(dm3&15)`, `dm3>>4`, `len-14`);
  len 3..12 -> `(len<<4)|(dm3&15)`, `dm3>>4`. len<3 -> literal.
- bound `a6 >= out+InLen` -> -17 (checked per symbol after flush).
- end: `d3==15` -> reclaim empty slot (`a6-=2`), else write flag
  word BE to slot; OutLen = a6-out at xsp+16.

## Decoder (0x54a) highlights

- regs: a3 in-cursor, a5 in-end, a4 out-cursor, a2 out-base,
  a6=tab16, d5=4 (shift count), d2 flag word, d3 bit idx.
- flag word read via stack byte trick = BE order; `a3>=a5` checked
  AFTER the read (2-byte overread).
- class 3..13: `d0 = -1 - b2; rol4; -lo` -> a1 = a4-2+sext(w) =
  a4-(16*b2+lo+3); dbf d4(=cls-1)+1 copies.
- class 1: N=lo+16*b1; if out odd emit b2,N--; then 4 longs+word
  (18 bytes) of b2s; if N<0 skip; tail `N>>2` longs + `N&3`+1 bytes.
- class 15: dist=lo+3+16*b2; cnt=b3+13; odd dist -> byte path
  (cnt+1); else odd src -> prepend byte,cnt--; longs*(cnt>>2) +
  bytes*(cnt&3)+1.
- produced length written at xsp+12 (a0 had advanced 12 via the
  initial moveml: InBuf/InLen/OutBuf).
