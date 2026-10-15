---
file: log
---
# Work log

- 2026-10-15: notifyintuition 2.40 — flat single-hunk lib,
  declared==physical 0x4b2 longs, RELOC32 tail 17 slots
  ->h0, END. Raw .byte h0 + generic fixup; BYTE-IDENTICAL.
  machine68k oracle: AUTOINIT init (FindTask guard,
  OpenLibrary dos/intuition/utility, CreateNewProc stub),
  Open x2 (subtask respawn attempt each Open since the
  stubbed proc never registers), reserved -24,
  NotIStartNotify error matrix (102/99/100/102) + two
  real registrations (pri-sorted Insert, InitSemaphore
  node, Signal bit14), dup UniqueID same-task allowed,
  re-register -> -4, NotIFindUniqueTask hit/miss,
  NotIEndNotify x2 (Remove/FreeVec), Close x2, real
  Expunge (CloseLibrary x3 + FreeMem). RUNTIME-IDENTICAL,
  invalids=0.
