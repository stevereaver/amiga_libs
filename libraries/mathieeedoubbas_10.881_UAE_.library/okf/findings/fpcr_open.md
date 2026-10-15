---
type: Finding
title: FPCR write in Open
description: Open programs the 68881 control register unconditionally.
---

# FPCR write in Open

The shipped Open is, verbatim:

```asm
moveq   #0x10,d0
fmove.l d0,fpcr                 ; FPCR := 0x10, unconditional
addq.w  #1,$20(a6)              ; lib_OpenCnt++
bclr.b  #3,$e(a6)               ; clear LIBF_DELEXP
move.l  a6,d0
rts
```

0x10 sets FPCR rounding mode to **round-toward-zero** (RM bits = 01),
precision = extended. Every Open reprograms the FPU — a side effect a
caller may not expect. (An earlier draft of this finding described a
read-modify-conditional-write sequence from a different build; this
binary has no such code — verified in the byte-identical asm rebuild
and the machine68k oracle.)
