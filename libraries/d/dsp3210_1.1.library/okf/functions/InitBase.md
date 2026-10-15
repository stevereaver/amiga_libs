---
type: Function
title: InitBase
description: MakeLibrary libInit hook; fills the base fields manually.
timestamp: 2026-10-10T20:10:00Z
---

# Signature

```c
struct DSP3210Base *InitBase(struct DSP3210Base *base, BPTR seglist);
/*                           d0                          a0          */
```

# Semantics

Stores `db_SegList`; writes `ln_Type` = NT_LIBRARY, `ln_Name` =
"dsp3210.library", `lib_Version` = 1, `lib_Revision` = 1,
`lib_IdString` = post-cookie `$VER` pointer, `lib_OpenCnt` = 0;
returns the base. There is no InitStruct data anywhere in the module —
this routine is the entire data-init path.
