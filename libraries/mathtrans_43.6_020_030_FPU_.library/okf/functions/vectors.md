# Vectors — mathtrans 43.6 6888x

Word-offset functab at code+0x8c (`0xffff` markers), 22 entries.
All offsets are code-hunk relative.

| LVO | Addr | Name | FPU op |
|-----|------|------|--------|
| -6  | 0x100 | Open | — |
| -12 | 0x110 | Close | — |
| -18 | 0x124 | Expunge | — |
| -24 | 0x000 | null (`moveq #0,rts`) | — |
| -30 | 0x1f4 | SPAtan | `fatans` |
| -36 | 0x26c | SPSin | `fsins` |
| -42 | 0x2e4 | SPCos | `fcoss` |
| -48 | 0x35c | SPTan | `ftans` |
| -54 | 0x81c | SPSinCos | `fsincoss` (d0→*d1, fp1→d0) |
| -60 | 0x3e4 | SPSinh | `fsinhs` |
| -66 | 0x45c | SPCosh | `fcoshs` |
| -72 | 0x4d4 | SPTanh | `ftanhs` |
| -78 | 0x54c | SPExp | `fetoxs` |
| -84 | 0x5c4 | SPLog | `flogns` |
| -90 | 0x168 | SPPow | `flogns;fsglmuls;fetoxx` (2-arg) |
| -96 | 0x63c | SPSqrt | `fsqrts` |
| -102 | 0x3d4 | SPTieee | expand only (packed→IEEE) |
| -108 | 0x914 | SPFieee | pack only (IEEE→packed); shared tail for SPSinCos |
| -114 | 0x6b4 | SPAsin | `fasins` |
| -120 | 0x72c | SPAcos | `facoss` |
| -126 | 0x7a4 | SPLog10 | `flog10s` |
| -132 | 0x89c | (extra) | `ftentoxs` — 10^x, beyond standard mathtrans API |

## Stub structure

Every 1-arg vector = `EXPAND d0` + `f<op>.s d0,fp0` + `fmoves fp0,d0` + `PACK` + pad nops.

- **EXPAND** (14 B/reg): `addl dn,dn / beqs done / lsrb #1 / addib #62 / swap / roll #7` —
  converts `[mantissa24 | s:1+exp:7 (bias 64)]` to IEEE single. `0x80000041`→`0x3f800000` (1.0), `0x800000c1`→`0xbf800000` (-1.0). Zero input passes through as IEEE +0.
- **PACK** (~96 B): `swap / rorl #7 / eorib #-128 / addb d0,d0` then
  - `bvs` → overflow/denormal fix block (`cmpib #124/#126`, `addib #-123`, retest)
  - normal: `addqb #5`, `bvs` → saturate, else `eorib #-128; rorl #1; rts`
  - `bccs` small path (`cmpib #-2`, `andil #0xf8000000`)
  - saturate: `moveq #-1; lsrb #1; orib #2,%ccr; rts` → returns `0x7fffffff` with CCR X-ish bit set (failure flag)
- Nop pads per block keep every stub on its fixed offset; counts vary (pow 0/2/3/1, sincos 1/2/3/1, fieee 2/2/3/0, all others 3/2/3/1).

## Lifecycle

- **Init** (0xdc): stores SysBase@+34, seglist@+38, tests `AttnFlags` bit 4; seeds `OpenCnt` (+32) to **1** on success.
- **Open** (0x100): `OpenCnt++`, `bclr #3,+42` (LIBF_DELEXP), returns base.
- **Close** (0x110): `OpenCnt--`; expunges only if cnt==0 AND deferred bit set.
- **Expunge** (0x124): if OpenCnt≠0 → set LIBF_DELEXP, return 0. Else `Remove` (-252) + `FreeMem` (-210) of `lib-NegSize .. +PosSize`, returns seglist.
