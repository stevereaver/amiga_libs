---
type: Function
title: LibClose
description: lib_OpenCnt--; on reaching 0 unlinks the node from the exec list and FreeMem()s the base, returning the seglist.
lvo: -12
registers: -
---

# `BPTR LibClose(void)`

**LVO -12** — implicit `a6` = library base.

Disassembly (text+0x94):

```
subq.w  #1,32(a6)        ; lib_OpenCnt--
bne.s   done             ; still open -> rts with stale d0
movem.l d2/a5-a6,-(sp)
movea.l a6,a5
move.l  38(a5),d2        ; d2 = vb_SegList (return value)
movea.l a5,a1            ; inlined Remove():
movea.l (a1)+,a0         ;   a0 = ln_Succ
movea.l (a1),a1          ;   a1 = ln_Pred
move.l  a0,(a1)          ;   pred->ln_Succ = succ
move.l  a1,4(a0)         ;   succ->ln_Pred = pred
movea.l 34(a5),a6        ; a6 = vb_SysBase
movea.l a5,a1
moveq   #0,d0
move.w  16(a5),d0        ; d0 = lib_NegSize
suba.l  d0,a1            ; a1 = base - NegSize (block start)
add.w   18(a5),d0        ; d0 = NegSize + PosSize
jsr     -210(a6)         ; exec FreeMem
move.l  d2,d0            ; return seglist
movem.l (sp)+,d2/a5-a6
done:
rts
```

Notes:

- The removal is **unconditional** on OpenCnt reaching 0 -- no
  LIBF_DELEXP test.  Combined with the no-op Expunge vector this
  means the library always expunges itself at last Close.
- The node unlink is open-coded (equivalent to exec `Remove()`),
  not a vector call.
- The still-open path leaves d0 unmodified (whatever the caller
  had); the C reconstruction returns NULL there.  See
  [RebuildDeviations](../findings/RebuildDeviations.md).
