---
type: Structure
title: ZLibBase
description: Library base — plain struct Library, no private data.
---

# ZLibBase

```c
struct ZLibBase { struct Library zb_lib; };
```

AUTOINIT `dataSize` = 0x22 = `sizeof(struct Library)` — no private fields, so
the library keeps its globals in the shared DATA hunk (SAS/C/StormC near-data):
`_SysBase`, `DOSBase`/`powerpc.library` base pointer, init/exit lists, and the
zlib error-string table all live there (base-relative addressed).

InitStruct fields set at MakeLibrary time: `ln_Type=NT_LIBRARY(9)`,
`ln_Name="zlib.library"`, `lib_Flags=LIBF_SUMUSED|LIBF_CHANGED(6)`,
`lib_Version=3`, `lib_Revision=2`, `lib_IdString`="$VER:...".
