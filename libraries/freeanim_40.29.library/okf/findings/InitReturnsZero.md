---
type: Finding
title: Init routine returns 0
description: The InitTable initFunc is the shared null stub, so loading this library always fails.
timestamp: 2026-10-10T18:00:00Z
---

# Init routine returns 0

The InitTable's initFunc pointer and all four function-table entries
point at the same `moveq #0,d0 / rts`.  Exec's `MakeLibrary` treats a
NULL return from the init function as failure: the just-allocated
library is released and `InitResident` fails.  Consequently this file
can be *found* by `FindResident` but can never actually be installed —
`OpenLibrary("freeanim.library")` on it will always fail.

Open question: deliberate decoy/poison pill (the name suggests a
"FreeAnim"-clone blocker, see the functionally complete 40.9 build) or
a generator artifact?  The reconstruction reproduces the behavior
bit-for-bit anyway.
