---
file: defects
---
# Findings

- Carried over from 2.40/2.41 (still present in 3.04):
- The "is node in the +0x80 list" helper (h0+0xd20)
  is still broken: it walks the list comparing each
  node against its argument but never stores a
  result — it always returns the argument unchanged
  (nonzero when the node ptr is nonzero). The -3
  INRERROR_UNKNOWN path in NotIEndNotify remains
  unreachable dead code; EndNotify "unregisters"
  any request whose +0x2c holds a non-list pointer
  (oracle: unregistered request -> ret req, err 0).
- The public semaphore "notifyintuition.library"
  (lib+0x52, AddSemaphore'd by the subtask) is
  used by -30/-36/-42 purely as an external lock:
  FindSemaphore + AttemptSemaphore, while the
  matching ReleaseSemaphore targets lib+0x52
  directly rather than the found pointer.
- Naming via 0xab/0xbb quoted strings
  (" notify_subtask ", " notify_int Patches ") and
  idstring with 0xa0 NBSP + 0xa9 (c). The RomTag
  id points inside the "$VER: " string at +0x3c —
  one string serves both $VER and idstring (the
  name string similarly serves OpenLibrary via its
  "intuition.library" suffix at +0x26).
- initfn double-load guard: FindTask on the
  library's own name — a second copy fails init
  only while the first's subtask is registered
  under that name.
- Open respawns the subtask whenever lib+0x36 == 0;
  under the stub harness every Open logs another
  CreateNewProc — deterministic, the real subtask
  sets +0x36 on entry.
- InitStruct writes byte 9 to lib+0x0c which is
  inside the ln_Name long and is overwritten by the
  very next record — harmless dead init byte.

## 3.04-specific

- Expunge is a dead stub: functab -18 and -24 both
  point at `moveq #0,d0; rts` (h0+0xad8). The whole
  2.41 expunge (CloseLibrary x3, Remove, FreeMem,
  subtask signal-wait loop, DELEXP latch logic) is
  gone. Close no longer sets LIBF_DELEXP either —
  lib_Flags stays 0x06 after a final Close. The
  library can never be expunged at runtime.
- The embedded fake screennotify.library lives
  INSIDE the code hunk (h0+0x144 vectors /
  h0+0x180 struct) and is initialised by direct
  writes into the loaded code image — its OpenCnt,
  ln_Name ptr and real-lib back-pointer (+0x22)
  all live in "code" bytes. Self-writing hunk quirk.
- The fake lib claims lib_Version=2 rev=0 and
  borrows the notifyintuition idstring — clients
  see a "screennotify.library" named v2.0 whose
  id says "notifyintuition 3.04".
- sn -30/-42/-54 requests are built with flags
  0x01800110/0x01800400/0x0180c010 — bits 23/24
  are the screennotify class marker (bit24 doubles
  as the port-delivery class), and bit4 (0x10) is
  set in all three but filtered out by the
  0x1ffc0 event mask — dead flag bit.
- 2.41's low-memory dead routine (`movew d0,0x0`;
  Wait(0)) is gone — no abs-address stores found.
- The -42 vector's owner check stores ThisTask in
  node+0x32 at register time; FindUniqueTask
  compares a caller's d0=UniqueID only, so a
  second task sharing the ID still hits 98 at
  register.
- Under the oracle: init/open/close/expunge, all
  seven main vectors and all ten fake screennotify
  vectors run clean; invalids=0; log byte-identical
  between original and rebuild.
