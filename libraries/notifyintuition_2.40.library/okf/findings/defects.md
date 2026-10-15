---
file: defects
---
# Findings

- h0+0xb08 "is node in the +0x80 list" helper is broken:
  it walks the list comparing each node against its
  argument but never stores a result — it always returns
  the argument unchanged (nonzero when the node ptr is
  nonzero). Consequently the -3 INRERROR_UNKNOWN path at
  h0+0xafc in NotIEndNotify is unreachable dead code;
  EndNotify happily "unregisters" any request whose
  +0x2c field holds a non-list pointer.
- Dead routine h0+0x268: `moveq #0,d0; movew d0,0x0;
  moveal 4,a6; jsr -318(a6)` writes word 0 to address
  $000000 then Wait(0) — unreferenced, would touch low
  memory (invalid-access under the oracle).
- The public semaphore "notifyintuition.library" (the
  lib's own lib+0x52 SignalSemaphore, AddSemaphore'd by
  the subtask) is used by Start/EndNotify purely as an
  external lock: FindSemaphore + AttemptSemaphore, but
  the matching release targets lib+0x52 directly rather
  than the found pointer.
- Naming via 0xab/0xbb quoted strings (" notify_subtask
  ", " notify_int Patches ") and idstring with 0xa0
  NBSP + 0xa9 (c); the plain "$VER:" copy at h0+0x36 is
  unreferenced — RomTag points at h0+0x3c.
- initfn double-load guard: FindTask on the library's
  own name — a second copy fails init only while the
  first's subtask is registered under that name.
- Open respawns the subtask whenever lib+0x36 == 0;
  under the stub harness (CreateNewProc never runs the
  entry) every Open logs another CreateNewProc —
  deterministic, and the real subtask is expected to set
  +0x36 on entry.
- Expunge only proceeds when LIBF_DELEXP (bit3, +0xe)
  was already set — i.e. after a final Close or a prior
  refused Expunge; the first Expunge on a clean-opened
  lib latches the flag and returns 0.
- InitStruct writes byte 9 to lib+0x0c which is inside
  the ln_Name long and is overwritten by the very next
  record — harmless dead init byte.
- Under the oracle: init/open/close/expunge and all
  three user vectors run clean; invalids=0; log
  byte-identical between original and rebuild.
