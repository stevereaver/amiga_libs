---
type: Algorithm
title: PortProtocol
---

# Launcher dispatch protocol

Shared helper (hunk+0x100), called with the wanted key in d0:

1. `FindPort("GhostRider.Port")` -> NULL => return -2.
2. `tab = *(APTR *)(port + 0x22)`; walk `{u16 key, u32 fn}`
   entries while `key >= 0`; on `key == wanted`, a4 = fn,
   return 0.  Fall off the end => -2.

Callers:

- GRDispatch (-30): key 0, arg in d0, all regs restored after.
- Input handler: key 0 via `bsr` to the -30 entry, d0=d1=0.
- GRCall6 (-42): key 6, arg in a0; Disable -> Supervisor(
  movec d4,vbr on 68010+) -> jsr (a4) -> CacheClearU -> Enable;
  returns fn's d0.
- GRCall7 (-48): key 7; same wrapper, also returns fn's d1.

The Disable/VBR/cache-flush wrapper around keys 6/7 suggests the
launcher uses them to install or relocate code (e.g. exception
or interrupt vectors) -- a reason to flush icache before
re-enabling interrupts.
