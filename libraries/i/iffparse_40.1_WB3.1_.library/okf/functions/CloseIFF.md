---
type: Function
title: CloseIFF
description: Drains the context stack (running exit handlers + LCI purge), flushes deferred writes, calls stream hook IFFCMD_CLEANUP.
lvo: -48
registers: a0
timestamp: 2026-10-10T18:00:00Z
---

# `void CloseIFF(iff)`

**LVO -48** — registers `a0`

Drains the context stack (running exit handlers + LCI purge), flushes deferred writes, calls stream hook IFFCMD_CLEANUP.
