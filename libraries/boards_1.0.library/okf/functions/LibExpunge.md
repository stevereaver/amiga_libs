---
type: Function
title: LibExpunge
description: Sets private flag if open; else Remove, CloseLibrary(expname), FreeMem.
lvo: -18
registers: a6 = library base
timestamp: 2026-10-10T18:00:00Z
---

# `ULONG LibExpunge(void)`

**LVO -18** (code+0x184) — registers `a6 = libbase`

Loads the *stored* SysBase (+0x24) into a6 for the OpenCnt test,
then performs `Remove`, `CloseLibrary(expnamebase)` if non-NULL, and
`FreeMem` through absolute ExecBase ($4).  Returns seglist (+0x28)
or 0 after setting the private flag at +0x23 bit0.
