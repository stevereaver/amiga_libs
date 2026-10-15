---
type: Finding
title: Shared code tails, in-CODE seglist cell, name-in-path string
description: Code-sharing and string-sharing quirks inside the 0x244-byte hunk.
---

# Shared code tails

The original compiler/linker squeezed the hunk by overlapping tails:

- **init-fail / Expunge free tail** (0xe8): the init routine's no-FPU
  path branches into the *middle* of Expunge, at the `moveq #0,d0;
  FreeMem(base - NegSize, NegSize+PosSize); d0 = segcell; rts` tail.
  Works because a1=libbase (restored from the stack) and a6=ExecBase in
  both contexts.  On the init path the segcell is still 0, which doubles
  as the failure return value.
- **Close -> Expunge fall-through** (0xc8): when OpenCnt reaches 0 and
  LIBF_DELEXP is set, Close falls directly into the Expunge entry.
- **moveq #0,d0; rts** (0xd4): one instruction pair is the reserved
  LVO -24 body, Close's "still open" return, Expunge's deferred return —
  *and* a branch target inside IEEESPPow (0^positive exp -> return +0,
  `fbogt 0xd4`).
- **Tieee/Fieee share Sincos's rts** (0x1a4): both vector slots point at
  the bare RTS that terminates IEEESPSincos — identity conversions need
  no code at all.
- **Seglist cell lives in CODE** (0x2c), not in the library base: init
  does `lea 0x2c(pc),a1; move.l a0,(a1)`, Expunge reads it back with
  `move.l 0x2c(pc),d0`.  Corollary: the 26 "private" bytes allocated by
  dataSize 0x3c (lib+0x22..0x3b) are never touched by any code — dead
  allocation.
- **rts at hunk+0** (executable entry) is a bare RTS, not the usual
  `moveq #-1,d0; rts` two-word stub seen in later libraries.
- **RomTag rt_Version = 45** while lib_Revision = 881: the AUTOINIT copy
  puts 45 into lib_Version and InitStruct puts 881 into lib_Revision, so
  the library reports version 45.881 even though the IdString says
  "MST 10.881".

# Name carved out of the NoFPU path

rt_Name (reloc @0x10) points at hunk+0x109 — **11 bytes inside** the
`"Libs:NoFPU/mathieeesingtrans.library"` path string at 0xfe.  The tail
`"mathieeesingtrans.library"` serves both as the OpenLibrary argument
for the no-FPU fallback and as the resident module's own name; no
standalone name string exists.  (Sibling mathieeesingbas carries a
dedicated name string instead.)
