---
type: Function
title: LibExpunge
description: Sets DELEXP when in use, else unlinks and frees the library.
lvo: -18
registers: a6 base -> d0 seglist|0
timestamp: 2026-10-10T21:10:00Z
---

# ``BPTR LibExpunge(void)``

**LVO -18**

When `lib_OpenCnt` is non-zero, sets `LIBF_DELEXP` and returns 0.
Otherwise calls `CloseLibs()` (workbench/dos/utility — see
[Quirks](../findings/Quirks.md) for the NULL-base crash path),
`Remove()`s the base node, frees the library memory block and
returns the seglist BPTR.
