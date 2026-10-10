---
type: Function
title: LibExpunge
description: Sets flag if open; else Remove, CloseLibrary(dos), FreeMem via stored SysBase.
lvo: -18
registers: a6 = library base
timestamp: 2026-10-10T18:00:00Z
---

# `ULONG LibExpunge(void)`

**LVO -18** — registers `a6 = libbase`

Uses the stored ExecBase (+0x22) for `Remove`, `CloseLibrary(dos)`
and `FreeMem`.  Register quirk: pushes `d1/a5-a6` but pops
`d2/a5-a6`, so the caller's d2 is overwritten with its old d1 value.
Returns seglist (+0x2a) or 0 after `bset #3,46(a5)`.
