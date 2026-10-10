---
type: Structure
title: GRBase
---

# GRBase -- library base (InitTable dataSize = 0x2a)

| offset | size | field |
|--------|------|-------|
| 0x00 | 34 | struct Library |
| 0x22 | 4  | gr_SegList -- BPTR seglist, stored by LibInit |
| 0x26 | 4  | gr_Sys -- SysBase, stored by LibInit (used by Expunge) |

Only 0x2a bytes; the real working state lives in a separate
static block embedded in the code hunk (see GRState) -- the
library is a singleton by design.
