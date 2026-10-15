---
type: Function
title: LibOpen
description: Standard library open — clears DELEXP, bumps lib_OpenCnt.
lvo: -6
registers: a6 base -> d0 base
timestamp: 2026-10-10T21:10:00Z
---

# ``struct Library *LibOpen(void)``

**LVO -6**

Standard open vector: clears `LIBF_DELEXP` in `lib_Flags`,
increments `lib_OpenCnt`, returns the library base in d0.
Identical semantics to the 45.1 original.
