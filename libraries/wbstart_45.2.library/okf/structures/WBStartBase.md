---
type: Structure
title: WBStartBase
description: Private library base, 0x38 bytes — same layout as the 45.1 original.
timestamp: 2026-10-10T21:10:00Z
---

# WBStartBase

```c
struct WBStartBase
{
    struct Library   wb_Lib;      /* 0x00 */
    BPTR             wb_SegList;  /* 0x24 */
    struct ExecBase *wb_SysBase;  /* 0x28 */
    struct Library  *wb_WBBase;   /* 0x2c workbench.library v45 */
    struct Library  *wb_UtBase;   /* 0x30 utility.library v40   */
    struct Library  *wb_DOSBase;  /* 0x34 dos.library v40       */
};                              /* dataSize 0x38              */
```

`wb_SysBase` is captured from a6 in the MakeLibrary initFunc;
`wb_SegList` from a0.  The three support bases are filled by
`OpenLibs` during init; they stay NULL on failure and
`CloseLibs` closes all slots unconditionally (see
[Quirks](../findings/Quirks.md)).
