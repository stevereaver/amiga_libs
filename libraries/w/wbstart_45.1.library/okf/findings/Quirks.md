---
type: Finding
title: Quirks
description: Oddities found in the shipped binary.
timestamp: 2026-10-10T20:00:00Z
---

# Quirks

- RomTag `rt_Version` is **2** and init writes `lib_Revision = 2`,
  although the file and IdString advertise 45.1 — the installed
  library will report version 2/revision 2 to Version queries.
- `WBStart` inverts the workbench result: returns **0** when
  `OpenWorkbenchObjectA` succeeded and **20** (RETURN_FAIL) on any
  failure, including a missing name tag.
- Module entry code returns **-1** (`moveq #-1,d0/rts`) — not
  loadable as a program.
- LVO -30 is a second reserved stub; the only user function sits
  at -36.
- `FreeVec` is called unconditionally on the taglist pointer —
  relies on FreeVec(NULL) being safe; likewise `UnLock(0)`,
  `CloseLibrary(0)`.
- The earlier suspicion of a "dead program-name variable" was
  wrong: the tag+1 handler (`MOVE.L D2,D6` at the jump-table
  target) does assign the name; IRA had misdecoded it as data.
