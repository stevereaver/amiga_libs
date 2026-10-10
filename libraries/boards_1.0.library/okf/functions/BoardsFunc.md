---
type: Function
title: BoardsFunc (name inferred)
description: Calls expname.library LVO -30 and returns the bitwise complement of the result.
lvo: -30
registers: unknown — argument registers pass through to expname -30 (none read by this wrapper)
timestamp: 2026-10-10T18:00:00Z
---

# `LONG BoardsFunc(...)`

**LVO -30** (code+0x1e2) — the only public vector

```
movem.l d1-d3/a0-a3/a6,-(sp)
movea.l expnamebase(pc),a6
jsr  -30(a6)          /* expname.library's first public vector */
not.l d0              /* ~result */
movem.l (sp)+,...
rts
```

All argument registers pass straight through to expname.library's
-30 function; the return value is its bitwise complement.  The real
name and parameter list are unknown — the original boards.library
by Torsten Bach decoded expansion manufacturer/product IDs into
names, and Körber's expname.library provided the same tables, so
this is most plausibly a manufacturer/product-to-name (or
validity) query wrapper.  The `not.l` suggests the inner function
returns an inverted-validity or error code.

**Internal calls:** `jsr -30(a6)` on expname.library base.
**Uncertainty:** function name and exact semantics inferred.
