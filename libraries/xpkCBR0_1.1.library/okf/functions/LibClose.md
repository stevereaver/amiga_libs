---
type: Function
title: LibClose
description: Library close vector.
---

# LibClose — LVO -12

`subqw #1,lib_OpenCnt`; on zero with `LIBF_DELEXP` set it
falls into the shared expunge tail (Remove + FreeMem via
absolute SysBase at 4.w, seglist from base+0x24).
Returns the seglist BPTR on expunge, else 0.
