---
type: Finding
title: LibInit calls its own null stub
timestamp: 2026-10-10T19:45:00Z
---

# Dead init-time hook

`_LibInit` stores SegList/SysBase, then `bsr`s the shared reserved
stub (which always returns 0) and branches on the result: nonzero
would free the freshly-initialized base and fail init. The call is
real in the binary — likely a vestigial `InitSubLib`-style hook that
was stubbed out for this build — but the fail path is dead code.

Reproduced in C as an `if (LibNull() != NULL)` check; gcc folds it
away since `LibNull` is a constant 0.
