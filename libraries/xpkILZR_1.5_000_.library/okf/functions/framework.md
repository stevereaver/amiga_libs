---
type: Function
title: xpkILZR framework (LibInit/Open/Close/Expunge)
---

# Framework

`dataSize 0x26` — base = `struct Library` + seglist at +0x22.

## LibInit(d0=base, a0=seglist)

Stores `a0` at base+0x22, returns base.  No dependencies.

## LibOpen(a6=base)

`lib_OpenCnt++`, `lib_Flags &= ~LIBF_DELEXP`, returns base.

## LibClose(a6=base)

`--lib_OpenCnt`; on zero with DELEXP set, falls through to
LibExpunge, else returns 0.

## LibExpunge(a6=base)

Open -> `lib_Flags |= LIBF_DELEXP`, return 0.
Closed -> `d2=seglist`, Remove(node), FreeMem(base-NegSize,
NegSize+PosSize), return d2.

## Null vector

The entry stub `moveq #0,d0; rts` serves LVO -24 (ExtFunc)
and -60 (XpksUnpackFree) via a BACKWARD word offset in the
functab (original `ff72` = -0x8e).
