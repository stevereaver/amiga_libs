---
file: defects
---
# Findings

- Carried over from 2.40 (all still present in 2.41):
- The "is node in the +0x80 list" helper is broken: it
  walks the list comparing each node against its
  argument but never stores a result — it always
  returns the argument unchanged (nonzero when the
  node ptr is nonzero). Consequently the -3
  INRERROR_UNKNOWN path in NotIEndNotify is
  unreachable dead code; EndNotify happily
  "unregisters" any request whose +0x2c field holds a
  non-list pointer (oracle: unregistered request ->
  ret 0, err 0).
- Dead routine h0+0x266: `moveq #0,d0; movew d0,0x0;
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
  deterministic, and the real subtask is expected to
  set +0x36 on entry.
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

## 2.41-specific

- InitTable dataSize grew 0xbc -> 0xc0 but nothing
  references lib+0xbc..0xbf — 4B of unused private tail.
- The string block is 2B shorter than 2.40's
  (idstring date), so RomTag endskip, bitmask table and
  InitTable all sit 2B lower; all code after initfn
  shifts +4 and the post-dispatch region +0x3c.
- The event-dispatch/handling region (h0+~0x45c..0x6e0)
  was reworked vs 2.40: same 13-way pc-indexed jump
  table (h0+0x510), but surrounding code was
  re-ordered and the patch-handler stubs (h0+0xde6..
  0x1080) gained an extra `move.l disp(a7),d7` argument
  fetch with matching `move.l d7,-(a7)` pushes —
  signatures/frames changed, semantics under the oracle
  unchanged.
- The installer (h0+0x1156) now contains an extra
  `bclr`-style bit-14 manipulation vs 2.40.
