---
type: Finding
title: No-FPU init path
description: Behaviour of the init routine when AttnFlags lacks AFF_68881.
---

# No-FPU init path

on missing AFF_68881: OpenLibrary("Libs:NoFPU/mathieeedoubbas.library",36),
CloseLibrary(result), then run the shared free tail on the *new* base and
fail the resident init.

The init routine runs with a6 = ExecBase, d0 = new base, a0 = seglist.

Shipped code (0x5e):

```
tstl  d0                     ; no base -> return 0
beq.s ret
btst  #4,0x129(a6)           ; AFF_68881
beq.s nofpu
lea   cell(pc),a1            ; FPU present: stash seglist @ 0x2c
move.l a0,(a1)
ret: rts
nofpu:                       ; 0x72
move.l d0,-(a7)              ; save NEW base
moveq  #36,d0                ; version 36
lea   nofpuname(pc),a1       ; "Libs:NoFPU/mathieeedoubbas.library"
jsr   -552(a6)               ; OpenLibrary
movea.l d0,a1
jsr   -414(a6)               ; CloseLibrary(a1)
movea.l (a7)+,a1             ; a1 = NEW base again
bra.s freetail               ; FreeMem(base-NegSize, Neg+Pos); d0=segcell
```

Unlike mathieeesingbas (which just frees its own base), doubbas first
opens and immediately closes the `Libs:NoFPU/` fallback library --
presumably to guarantee the software fallback is resident.  The
OpenLibrary result feeds *only* the CloseLibrary call; the free tail
then runs on the freshly allocated base popped off the stack into a1
(`movea.l (a7)+,a1`).

Correction to the previous note: an earlier version of this file claimed
the free tail freed the *fallback* library's base and that the pushed
copy of the new base was popped into d1 as a "dead restore".  Both wrong
-- `225f` is `movea.l (a7)+,a1`, and the oracle confirms it: on the
no-FPU path FreeMem is logged with `new_base - NegSize`, while the
OpenLibrary result only appears as the CloseLibrary argument.  If
OpenLibrary fails, CloseLibrary is still called with a NULL a1 (which on
a real ExecBase would dereference garbage near address 0 via
lib_NegSize -- a latent crash path, but unreachable in practice since
OpenLibrary of a missing file returns cleanly).

The seglist cell at code+0x2c was never written on this path, so the
tail's `move.l cell(pc),d0` returns 0 -- the init routine's failure
return, exactly as in singbas.
