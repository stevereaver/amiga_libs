---
type: Structure
title: LauncherTable
---

# Launcher function table (GhostRider.Port protocol)

The launcher task owns a public port named `GhostRider.Port`.
GhostRider.library `FindPort()`s it and reads the longword at
**port+0x22** -- one longword past a standard 34-byte MsgPort --
as a pointer to an array of 6-byte entries:

```
struct GREntry {
    UWORD key;    /* compared against requested id; negative ends */
    APTR  fn;     /* LONG (*fn)() invoked via jsr */
};
```

Keys observed: 0 (input-trigger callback, invoked by the handler
and by GRDispatch), 6 (GRCall6), 7 (GRCall7).  Others are
possible but unobserved.

The port itself must be allocated larger than a standard MsgPort
for the +0x22 field to exist -- part of the private protocol
between this library and the launcher binary.
