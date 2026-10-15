---
type: Finding
title: Shared code tails and the in-CODE seglist cell
description: Code-sharing quirks inside the 0x1c8-byte hunk.
---

# Shared code tails

The original compiler/linker squeezed the hunk by overlapping tails:

- **init-fail / Expunge free tail** (0xca): the init routine's no-FPU
  branch jumps into the *middle* of Expunge, at the `moveq #0,d0;
  FreeMem(base - NegSize, NegSize+PosSize); d0 = segcell; rts` tail.
  Works because a1=libbase (set at 0x62) and a6=ExecBase in both
  contexts.  On the init path the segcell is still 0, which doubles as
  the failure return value — the seglist store at 0x70 is skipped.
- **Close -> Expunge fall-through** (0xa8): when OpenCnt reaches 0 and
  LIBF_DELEXP is set, Close falls directly into the Expunge entry.
- **moveq #0,d0; rts** (0xb6): one instruction pair is the reserved
  LVO -24 body, Close's "still open" return, and Expunge's deferred
  return.  The vector table just points -24 at it (offset 0x86).
- **Cmp/Tst shared constants** (0x118/0x128/0x12a): `moveq #1,d0`,
  `beq`, and `moveq #-1,d0`/`rts` blocks are branch targets shared by
  IEEESPCmp and IEEESPTst; Cmp also falls back into the Tst entry
  (`beq.s _IEEESPTst`) when the right operand is 0.
- **Seglist cell lives in CODE** (0x2c), not in the library base: init
  does `lea 0x2c(pc),a1; move.l a0,(a1)`, Expunge reads it back with
  `move.l 0x2c(pc),d0`.  Corollary: the 26 "private" bytes allocated by
  dataSize 0x3c (lib+0x22..0x3b) are never touched by any code — dead
  allocation.
- **rts at hunk+0** (executable entry) is a bare RTS, not the usual
  `moveq #-1,d0; rts` two-word stub seen in later libraries.
- **RomTag rt_Version = 45** while lib_Revision = 881: the AUTOINIT
  copy puts 45 into lib_Version and InitStruct puts 881 into
  lib_Revision, so the library reports version 45.881 even though the
  IdString says "MSB 10.881".
