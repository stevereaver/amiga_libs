---
type: Function
title: FwFilterType
description: Compares 4 type bytes at field+0x0c against "alph"; returns 3 and a "fwpha" string pointer on match.
lvo: -30
tags: [user-function, filter]
timestamp: 2026-10-10T19:15:00Z
---

# Signature

```c
ULONG FwFilterType(UBYTE *field, STRPTR *out, ULONG unused);
/*                  a0           a1            d0          */
```

# Semantics

- Compares exactly 4 bytes at `field + 0x0c` against `"alph"` (the stored
  constant is `"alpha\0"` but only 4 bytes are tested).
- On match: `result = 3`; if `out != NULL`, `*out = "fwpha"`.
- On mismatch: returns 0, `*out` untouched.
- The `d0` argument is pushed onto the stack in the original but never
  read — effectively `unused`.

# Notes

- This is the library's sole user function — the binary is essentially a
  type-name translation service: a field naming `alph*` maps to the
  `"fwpha"` filter/type string. Callers and the structure containing the
  +0x0c type field are unknown (no header/docs ship with the binary).
- The original emits a dead `cmpi.w #$4294,d0` after the store — flags
  are never consumed before the function returns; likely leftover code
  or a compiler quirk. Reproduced as a note only, not in C.
- Register prologue is unusual: `subq.w #4,a7` then `movem` — the extra
  4-byte frame slot holds the unused d0.
- `"alph"`/`"fwpha"` are 4-byte type tokens; "fw" prefix matches the
  library name (SoftWood family naming, cf. fwpha filter names).
