---
type: Function
title: LibExpunge
description: If OpenCnt, set LIBF_DELEXP and return 0; else Remove + FreeMem, return seglist.
lvo: -18
registers: a6 = library base
timestamp: 2026-10-10T18:00:00Z
---

# `ULONG LibExpunge(void)`

**LVO -18** (code+0x94) — registers `a6 = libbase`

Standard expunge using the absolute ExecBase at $0004: when
OpenCnt!=0 sets LIBF_DELEXP (bit 3 of lib_Flags) and returns 0;
otherwise seglist=+0x22, `Remove(base)`, `FreeMem(base-NegSize,
NegSize+PosSize)`, returns seglist.  Sizes read as words
(zero-extended) — standard exec convention.
