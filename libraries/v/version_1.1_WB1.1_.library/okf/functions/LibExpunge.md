---
type: Function
title: LibExpunge
description: Buggy expunge: Remove via a0 and wild FreeMem size math.
lvo: -18
registers: a6=library base
timestamp: 2026-10-10T19:00:00Z
---

# `BPTR LibExpunge(void)`

**LVO -18** — `a6` = library base on entry.

While `lib_OpenCnt` is non-zero the routine only sets the
deferred-expunge flag (base+42, bit 3) and returns 0; Close runs the
real expunge when the last user closes.

The 1.1 free path differs from all later builds and is buggy:

```
move.l  38(a5),d2        | seglist
movea.l a5,a0            | BUG: Remove takes the node in a1
jsr     -252(a6)         | exec Remove
movea.l a5,a1
move.l  16(a5),d0        | BUG: longword read of NegSize|PosSize
suba.l  d0,a1
add.l   18(a5),d0        | BUG: adds longword PosSize|lib_Version
jsr     -210(a6)         | exec FreeMem (wild address/size)
move.l  d2,d0
```

`suba.l d0,a1` subtracts `(NegSize<<16)|PosSize` from the base instead
of NegSize, and the size passed to FreeMem is the same garbage long plus
`(PosSize<<16)|lib_Version`.  Expunging this library under Kickstart 1.1
corrupts the free pool.  See findings/BuggyExpunge.md.

