---
type: Function
title: LibExpunge
description: Deferred while open; otherwise unlinks the node and frees the base.
lvo: -18
registers: a6=library base
timestamp: 2026-10-10T19:00:00Z
---

# `BPTR LibExpunge(void)`

**LVO -18** — `a6` = library base on entry.

While `lib_OpenCnt` is non-zero the routine only sets the
deferred-expunge flag (base+42, bit 3) and returns 0; Close runs the
real expunge when the last user closes.

Otherwise it unlinks the library node, frees the base block and
returns the seglist:

```
movem.l d2/a5-a6,-(sp)
movea.l a6,a5            | a5 = base
movea.l 34(a5),a6        | SysBase (stored by the init vector)
tst.w   32(a5)           | lib_OpenCnt
beq     free
bset    #3,42(a5)        | deferred expunge
moveq   #0,d0
bra.s   out
free:
move.l  38(a5),d2        | seglist
movea.l a5,a1            | node
jsr     -252(a6)         | exec Remove
movea.l a5,a1
moveq   #0,d1
moveq   #0,d0
move.w  16(a5),d1        | lib_NegSize
suba.l  d1,a1
move.w  18(a5),d0        | lib_PosSize
add.l   d1,d0            | size = NegSize + PosSize
jsr     -210(a6)         | exec FreeMem
move.l  d2,d0
out:
movem.l (sp)+,d2/a5-a6
rts
```

