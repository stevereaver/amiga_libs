---
type: Function
title: xpkNUKE_1.9 vector map
timestamp: 2026-10-14T00:00:00Z
---

# Vectors (all code offsets relative to hunk start)

| LVO  | offset | function |
|------|--------|----------|
|  -6  | 0x244  | LibOpen — opencnt++, forbid-flag, returns lib |
| -12  | 0x252  | LibClose — opencnt--; deferred expunge or null |
| -18  | 0x260  | LibExpunge — opencnt>0 sets LIBF_DELEXP ret 0 |
| -24  | 0x296  | LibNull (moveq #0,d0; rts) |
| -30  | 0x29a  | XpksPackerInfo — returns &descriptor (code+0x120) |
| -36  | 0x2a2  | XpksPackChunk |
| -42  | 0x6f2  | XpksPackFree |
| -48  | 0x296  | LibNull |
| -54  | 0x716  | XpksUnpackChunk |
| -60  | 0x296  | LibNull |

Functab is the word-offset flavour (pairs of `dc.w target-base`),
generated two-pass by `source/genfunctab.py`.  LibInit at code+0xd8
stores the seglist at lib+0x38 and returns the lib base; there is no
CPU-type gate.

## XpksPackChunk (a0=xsp)

Reads `xsp_InBuf/InLen/OutBuf/OutBufLen`.  `xsp_Sub[0]` caches a
196,700-byte workspace (`+92 hdr | +92 tab1[64K w] | +92+0x20000
tab2[32K w]`); on reuse both tables are zeroed with a 0x30000-byte
clear.  Position counters and stream pointers are initialised, then
the main loop runs one position at a time (see `algorithms/codec.md`).

Return values: `0` + `xsp_OutLen` on success; `-17` (XPKERR_EXPAND)
when the compressed output would not shrink the input — including all
incompressible inputs and every input under ~16 bytes.  `xsp_OutLen`
is still written with the attempted length on failure.

Init details reproduced exactly:

- `litptr = dst + (SHORT)(OutBufLen-4)` and `srcend = src +
  (SHORT)InLen` — **sign-extended word** adds (`addaw`); OutBufLen
  above 0x7fff wraps the literal pointer below dst (the original
  breaks the same way — oracle uses 0x8000).
- Clear loop `clrl a4@(0x28,d0)` covers workspace +40..+63
  (litcnt/window get rewritten immediately after); a second loop
  stores `&scratch` (a4+80) at +64..+79 (ptr1..ptr4).
- `litcnt = -1`, `litstart = 0`, `window = 0x6a8f`,
  `lastpos = inlen-1`, `d5 = 1` (first candidate position).

## XpksPackFree (a0=xsp)

Frees the cached workspace via exec FreeMem(a1=wm) and writes `0` to
`xsp_Sub[0]`.  Returns 0 when nothing cached, otherwise whatever
FreeMem leaves in d0.  The call sites patch the SysBase fetch into a6
with inline asm (register arg, not the C ABI).

## XpksUnpackChunk (a0=xsp)

Reads the four interleaved forward bit streams plus the backward
literal region produced by the packer (see codec doc).  Writes
`xsp_OutLen`; returns 0.  Streams are read with per-stream counters
exactly mirroring the emit side (flag/2-bit/nibble/xbits), and
offsets are looked up through the same class table at code+0x17c.

## XpksPackerInfo

Returns the address of the 96-byte descriptor at code+0x120
(short `NUKE`, long `Nuke`, both pack+unpack mode entries).
