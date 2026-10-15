---
file: log
---
# Work log

- 2026-10-15: notifyintuition 2.41 — flat single-hunk
  lib, declared==physical 0x4c1 longs, RELOC32 tail 17
  slots ->h0, END. Raw .byte h0 + generic fixup (same
  as 2.40); BYTE-IDENTICAL on first build.
  machine68k oracle: AUTOINIT init (FindTask guard,
  OpenLibrary dos/intuition/utility, CreateNewProc
  stub NP_Entry=h0+0x278), Open x2 (subtask respawn
  attempt each Open since the stubbed proc never
  registers), reserved -24, NotIStartNotify error
  matrix (102/99/100/102) + two real registrations
  (pri-sorted Insert, InitSemaphore node, Signal
  bit14), dup UniqueID same-task allowed,
  re-register -> -4, NotIFindUniqueTask hit/miss,
  NotIEndNotify x2 (Remove/FreeVec), Close x2, real
  Expunge (CloseLibrary x3 + FreeMem).
  RUNTIME-IDENTICAL, invalids=0.
  Delta vs 2.40: rev 41 (12.7.96), hunk +60B,
  dataSize 0xbc->0xc0 (unused tail), vectors +4,
  patch table h0+0x11be->0x11fa, trampolines
  h0+0x1238->0x1274, dispatch/handlers reworked;
  oracle output identical modulo offsets.
