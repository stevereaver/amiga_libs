---
bundle: notifyintuition_2.41.library
status: complete
updated: 2026-10-15
---
# notifyintuition.library 2.41 (12.7.96)

Intuition notification library by H.-W. Schober (aminet
util/libs/NotInt24). Single flat CODE hunk (0x4c1 longs,
4988B file). AUTOINIT resident @h0+4 (ver 2, NT_LIBRARY),
InitTable @h0+0xe2. 7 absolute-long vectors: the 4 standard
plus NotIStartNotify/NotIEndNotify/NotIFindUniqueTask.

The init function spawns a background process
("notifyintuition.library", NP_Priority 5) via dos
CreateNewProc(-498). The subtask owns two MsgPorts, a
registered public SignalSemaphore named like the library,
a 311-byte patch-context block (" notify_int Patches ")
holding a named semaphore + 12 dispatch stubs copied from
h0+0x1274, and SetFunction(-420) patches on 12 intuition
vectors (screen/window/workbench open-close-front-back)
per the record table @h0+0x11fa. Registered
IntNotifyRequest's hang off a priority-sorted MinList at
lib+0x80 and are signalled/messaged/called back by the
subtask when patched events fire.

Delta vs 2.40: version/revision bump, +4B private data,
patch-dispatch code reworked (+60B hunk); externally
identical under the oracle.

- `structures/layout.md` — hunk map, RomTag, InitTable,
  InitStruct image, lib-private offsets, patch table
- `functions/vectors.md` — LVO map + per-vector behaviour
- `findings/defects.md` — quirks and dead code
