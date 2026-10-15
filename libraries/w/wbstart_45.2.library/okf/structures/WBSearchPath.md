---
type: Structure
title: WBSearchPath
description: Workbench search-path list element returned by WBCTRLA_DuplicateSearchPath.
timestamp: 2026-10-10T21:10:00Z
---

# WBSearchPath

```c
struct WBSearchPath
{
    BPTR sp_Next;   /* BPTR to next element (0 = end) */
    BPTR sp_Lock;   /* BPTR dir lock of this element  */
};
```

Obtained via `WorkbenchControlA(NULL, {WBCTRLA_DuplicateSearchPath,
&list})`, walked with `BADDR()`, released with
`WBCTRLA_FreeSearchPath`.  Used by StartObject when a bare object
name is not found in the current directory: each element's lock
becomes the current dir for the next `LockObjectOrInfo` probe.
