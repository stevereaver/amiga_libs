---
type: Function
title: LibOpen
description: OpenCnt++, clears LIBF_DELEXP, returns the library base.
lvo: -6
registers: -
timestamp: 2026-10-10T18:00:00Z
---

# ``struct Library *LibOpen(void)``

**LVO -6** — registers `-`

Standard open vector: `bclr #3,lib_Flags` (LIBF_DELEXP),
`addq.w #1,lib_OpenCnt`, returns a6 (the base).
