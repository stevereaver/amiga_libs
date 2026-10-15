---
type: Finding
title: No-FPU init path
description: Behaviour of the init routine when AttnFlags lacks AFF_68881.
---

# No-FPU init path

Init runs with a6 = ExecBase, d0 = new lib base, a0 = seglist:

```asm
tst.l   d0
beq.s   ret                     ; d0==0 -> return
btst.b  #4,$129(a6)             ; AFF_68881
beq.s   nofpu
lea     cell(pc),a1             ; code+0x2c
move.l  a0,(a1)                 ; stash seglist
ret:    rts

nofpu:
move.l  d0,-(a7)                ; save NEW lib base
moveq   #0x24,d0                ; version 36
lea     nofpu_name(pc),a1       ; "Libs:NoFPU/mathieeedoubbas.library"
jsr     -0x228(a6)              ; exec.OpenLibrary
movea.l d0,a1
jsr     -0x19e(a6)              ; exec.CloseLibrary
movea.l (a7)+,a1                ; a1 = NEW lib base again
bra.s   freetail                ; -> Remove-less FreeMem of the NEW lib
```

The open-and-close pair tries to force the `NoFPU` fallback resident —
but the name passed is a **path** (`Libs:NoFPU/...`), which OpenLibrary
cannot resolve, so it always fails and CloseLibrary(0) is a no-op.

The quirk: after the close, `a1` is restored to the *new* library's base
(the pushed d0), and the shared free tail runs `FreeMem(base - NegSize,
NegSize + PosSize)` on **this just-initialized library** — without
Remove()ing it from exec's list first (the `bra` skips the hand-unlink
at 0xba). The result d0 is then the seglist cell at code+0x2c, which is
still 0 on this path, so init returns 0 -> resident init fails. Net
effect on a 68881-less machine: the library frees its own (still
list-linked) base and reports failure, leaving exec's library list
pointing at freed memory. Verified by the machine68k oracle: the trace
shows `openlib "Libs:NoFPU/..." -> 0`, `closelib 0`, `freemem(base-96,
190)`, return 0.
