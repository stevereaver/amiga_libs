---
type: Function
title: xpkNUKE_1.8(000) vector map
timestamp: 2026-10-15T00:00:00Z
---

# Vectors (all code offsets relative to hunk start)

| LVO  | offset | function |
|------|--------|----------|
|  -6  | 0xb8   | LibOpen — opencnt++, bclr LIBF_DELEXP, returns lib |
| -12  | 0xc6   | LibClose — opencnt--; ret-0 via code+0 stub, or falls into Expunge |
| -18  | 0xd8   | LibExpunge — opencnt>0 sets LIBF_DELEXP, ret via stub; else Remove+FreeMem, returns seglist (lib+0x22) |
| -24  | 0x000  | null -> entry stub `moveq #0,d0; rts` |
| -30  | 0x132  | XpksPackerInfo — lea code+0x8b8 (descriptor) |
| -36  | 0x13a  | XpksPackChunk |
| -42  | 0x116  | XpksPackFree |
| -48  | 0x000  | null -> entry stub |
| -54  | 0x79c  | XpksUnpackChunk |
| -60  | 0x000  | null -> entry stub |

Functab is the word-offset flavour (`ffff` marker, `dc.w target-base`
entries, `ffff` terminator) at code+0x98, generated two-pass by
`source/genfunctab.py`.  RomTag rt_EndSkip = 0 (sic).  LibInit at
code+0xb0 stores the seglist at lib+0x22 (34) and returns the lib
base; no CPU-type gate.  InitTable dataSize = 0x26.

## XpksPackChunk (a0=xsp)

Reads `xsp_InBuf/InLen/OutBuf/OutBufLen`.  `xsp_Sub[0]` caches a
196,700-byte workspace (`+92 hdr | +92 tab1[64K w] | +92+0x20000
tab2[32K w]`).  **Differs from 1.9 here:** the alloc uses
`AllocMem(196700, MEMF_ANY)` (flags=0, not MEMF_CLEAR) and then
explicitly `clrl`s the 12-byte scratch area at work+80; both hash
tables are zeroed on **every** call in the common path (tab1 via a
0x2000-iter x16B loop, tab2 via 0x2000-iter x8B loop) rather than only
on workspace reuse.

Return values: `0` + `xsp_OutLen` on success; `-17` (XPKERR_EXPAND)
when output >= input — including every input under ~16 bytes.
`xsp_OutLen` is written before the check, so failures leave the
attempted length (or 0xffffffff for the outcur>=litptr overflow).

Init details reproduced exactly:

- `litptr = dst + (SHORT)(OutBufLen-4)` and `srcend = src +
  (SHORT)InLen` — **sign-extended word** adds (`addaw`); OutBufLen
  above 0x7fff wraps the literal pointer below dst.
- Pack core (code+0x2e4) clears +44..+63 (ctr1-4 + acc1-4) then stores
  `&scratch` (a4+80) at +64..+79 (ptr1..ptr4).
- `litcnt = -1`, `litstart = 0`, `window = 0x6a8f`,
  `lastpos = inlen-1`, `d5 = 1` (first candidate position).

## XpksPackFree (a0=xsp)

Frees the cached workspace via exec FreeMem(a1=wm) and — **unlike
1.9 — does NOT clear `xsp_Sub[0]`**; the pointer stays stale, so a
subsequent PackChunk happily reuses the freed block (verified in the
oracle: the post-PackFree pack runs with no fresh AllocMem).  Returns
0 when nothing cached, otherwise whatever FreeMem leaves in d0.

## XpksUnpackChunk (a0=xsp)

Reads the four interleaved forward bit streams plus the backward
literal region (see codec doc).  Writes `xsp_OutLen`; returns 0.
Earlier-generation decoder than 1.9: compact layout, the nibble
extension block doubles as the 15-byte copy region entered mid-block
(`jmp pc@(0x880,d0)`), no unrolled copy run — same observable format.

## XpksPackerInfo

Returns the address of the descriptor at code+0x8b8 (short `NUKE`,
long `Nuke V1.8`, XpkMasterVersion field = 2, xi_MinPkInChunk = 0,
xi_DefMode = 100 — several field values differ from 1.9).
