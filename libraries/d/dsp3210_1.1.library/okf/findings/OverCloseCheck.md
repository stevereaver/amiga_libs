---
type: Finding
title: LibClose tests OpenCnt before decrementing
timestamp: 2026-10-10T20:10:00Z
---

# Over-close protection

`LibClose` does `tst.w lib_OpenCnt` **before** `subq.w #1` — closing a
library with OpenCnt already 0 returns NULL instead of decrementing
into 0xffff and triggering a spurious expunge path. Most skeleton
implementations (the version stubs, fwfiltertype, xpkNONE) decrement
unconditionally. Reproduced in C.

Also: the expunge call's return value is discarded — this Close always
returns 0/NULL even when it did expunge (standard skeletons return the
expunge result, i.e. the seglist).
