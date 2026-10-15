---
type: Function
title: ExtFunc
description: LVO -24 points at the module entry — returns 0.
lvo: -24
registers: -> d0 0
timestamp: 2026-10-10T22:30:00Z
---

# ExtFunc

**LVO -24**

The functab entry for -24 points at the module loader entry
itself (`moveq #0,d0; rts` at hunk offset 0) rather than a
dedicated stub — same net effect (return 0) and one less copy
of the instruction.  [IEEESPPow](IEEESPPow.md) also branches
here as its error exit.
