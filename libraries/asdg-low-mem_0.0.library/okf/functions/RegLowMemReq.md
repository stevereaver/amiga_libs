---
type: Function
title: RegLowMemReq
description: Register a client port name + LowMemMsg for the alert.
lvo: -30
registers: a0 portname, a1 msg, a6 base
timestamp: 2026-10-10T19:00:00Z
---

# ``LONG RegLowMemReq(STRPTR portName, struct Message *msg)``

**LVO -30** — `a0` = NUL-terminated port name, `a1` = LowMemMsg

- `FindName()` on the client list; duplicate -> returns -1
  (`LM_BADNAME`).
- Allocates `strlen+1` bytes for a private copy of the name, then a
  20-byte RegNode; either failure frees what was allocated and
  returns -2 (`LM_NOMEM`).
- Fills the node (`ln_Name`=copy, `+14`=msg, `+18`=nameLen,
  `ln_Type`/`ln_Pri`=0) and `AddHead()`s it.  Returns 0.

The message pointer itself is kept, not copied — the client's
LowMemMsg must stay allocated for the library's lifetime.
