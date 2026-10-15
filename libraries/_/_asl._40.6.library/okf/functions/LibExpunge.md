---
type: Function
title: LibExpunge
description: DELEXP if open; otherwise Remove + FreeMem via absolute ExecBase, returns seglist.
lvo: -18
registers: a6 = library base
timestamp: 2026-10-10T18:00:00Z
---

# `ULONG LibExpunge(void)`

**LVO -18** (code+0xca) — registers `a6 = libbase`

Standard expunge.  OpenCnt!=0 → `bset #3,14(a6)`, return 0.  Else
`Remove(base)` via exec at $0004, seglist=+0x2a,
`FreeMem(base-NegSize, NegSize+PosSize)`, return seglist.
