---
type: Structure
title: LibBase
description: Library base, dataSize 0x34 — struct Library + privates.
---

# LibBase

```
0x00  struct Library            (34 bytes)
0x22  UBYTE  private flag byte  — bclr #3 executed on every LibOpen
0x23  UBYTE  pad
0x24  APTR   lb_SysBase         — set by LibInit (a6)
0x28  BPTR   lb_SegList         — set by LibInit (a0)
0x2c  APTR   lb_DOSBase         — TaggedOpenLibrary(4) result
0x30  APTR   lb_OpenLib         — OpenLibrary("060.library") result,
                                  returned by LibOpen when non-NULL
```

The InitStruct table zeroes lb_OpenLib (entry `8030 0000 0000`).
