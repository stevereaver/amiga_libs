---
type: Function
title: xpkMASH_1.98(000) vector map
---

# Vectors (offsets relative to hunk/code start)

| LVO  | offset | function |
|------|--------|----------|
|  -6  | 0x1c4  | LibOpen — opencnt++, clears LIBF_DELEXP (bit3 @+0x0e), returns lib base |
| -12  | 0x1d2  | LibClose — opencnt--; at 0 with DELEXP set falls into Expunge |
| -18  | 0x1e2  | LibExpunge — opencnt>0 sets DELEXP, returns 0; else Remove+FreeMem, returns seglist |
| -24  | 0x220  | return-0 stub (moveq #0,d0; rts) |
| -30  | 0x34c  | XpksPackerInfo — returns &info block (code+0xae) in **d0** |
| -36  | 0x224  | XpksPackChunk |
| -42  | 0x32e  | return-0 stub (no PackFree state — allocs are freed inline) |
| -48  | 0x32e  | return-0 stub |
| -54  | 0x332  | XpksUnpackChunk |
| -60  | 0x32e  | return-0 stub |

Functab is the absolute-long flavour: ten `.long` entrypoints covered
by RELOC32, terminated by 0xffffffff.  Observed at runtime (lib
loaded at 0x40000): `1c4 1d2 1e2 220 34c 224 32e 32e 332 32e`.

LibInit (0x1b6) stores exec at lib+0x22 and the seglist at lib+0x26
and returns the base; no CPU-type gate.

## XpksPackChunk (a0=xsp)

```
movem.l d1-d7/a0-a6,-(sp); a5=lib, a4=xsp, a6=lib+0x22 (exec)
d3 = 0x20010; d7 = xsp_InLen
if InLen >= 0x10001: -> L_254  (second engine)
d3 += 2*InLen; AllocMem(d3, MEMF_PUBLIC) -> on success L_2ec
L_254: AllocMem(0x10000) -> a2  (chain table)
       d3 = 0x20000; d5 = 5 tries
L_276: AllocMem(d3) -> a3; on fail d3>>=1, retry, else L_2d4
L_28a: setup from xsp; call engine B (0x580); free both; join L_2cc
L_2ec: engine A (0x620): a3 = one big alloc, a2 = a3 + 0x20000
L_2cc: d7 != 0 -> xsp_OutLen = d7, return 0; else return -17
       alloc failure path -> return -7
```

Register conventions: a4 = xsp, a0 = InBuf cursor, a1 = OutBuf base,
a2 = record/link area, a3 = head/chain table, a5 = out-bound
(`OutBuf+InLen-10`, stored to xsp+0x3c), d7 = positions remaining.
`tries = 1 << (xsp_Mode/10)` (16-bit `divs.w #10` + `asl.w`) stored
at xsp+0x40.

Return values: `0` + `xsp_OutLen` on success; `-17` when the stream
did not shrink the input (compressor returned 0 -> empty,
incompressible, all inputs < 11 bytes); `-7` on AllocMem failure
(sign extension: `moveq #-17`/`-7` byte immediates).

## XpksUnpackChunk (a0=xsp)

No allocation at all.  `a1 = xsp_OutBuf; d0 = xsp_InLen` then jumps
into the straight-line decoder at 0x8aa; writes `xsp_OutLen` from
the decoded total, returns 0.

## XpksPackerInfo (a0=result)

`exg d0,a0; lea info(pc),a0; exg d0,a0; rts` -- d0 ends up holding
the info pointer (a0 unchanged).  The descriptor is embedded in the
code hunk at 0xae (see structures/layout.md).

## Reserved vectors

-24, -42, -48, -60 are two distinct `moveq #0,d0; rts` stubs at
0x220/0x32e (two copies — the function table references the 0x32e
one three times).  Both return 0 and touch nothing.

## Lifecycle notes

- Open/Expunge/Close behave exactly per exec convention
  (oracle: open x2 -> opencnt 2; expunge -> flags 0x0e, ret 0;
  close x2 -> deferred expunge runs Remove+FreeMem(0xa8)).
- FreeMem on expunge: `a1 = lib - negsize` (0x100000-0x3c = 0xfffc4),
  `d0 = negsize + possize` = 60+108 = 168 bytes; log shows
  `remove(0x100000)` + `freemem(0xfffc4, 168)`.
