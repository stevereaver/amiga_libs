---
type: Structure
title: LibBase
description: Library base, dataSize 0x38 — struct Library + privates.
---

# LibBase

```
0x00  struct Library            (34 bytes)
0x22  UBYTE  private flag byte  — bclr #3 executed on every LibOpen
0x23  UBYTE  pad
0x24  APTR   pb_SysBase         — set by LibInit (a6)
0x28  APTR   pb_OpenLib         — OpenLibrary("060.library") result,
                                  returned by LibOpen when non-NULL;
                                  pre-zeroed by the InitStruct table
0x2c  APTR   pb_LoadLib         — LoadSeg+InitResident result,
                                  pre-zeroed by the InitStruct table
0x30  BPTR   pb_SegList         — set by LibInit (a0)
0x34  APTR   pb_DOSBase         — OpenLibrary("dos.library") result
```

InitStruct zeroes +0x28 and +0x2c (entries `8028`/`802c`).
