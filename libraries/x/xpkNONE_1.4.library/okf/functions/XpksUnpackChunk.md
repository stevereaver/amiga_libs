---
type: Function
title: XpksUnpackChunk
description: Unpacks a stored chunk by plain CopyMem.
lvo: -54
timestamp: 2026-10-10T19:45:00Z
---

# Signature

```c
LONG XpksUnpackChunk(struct XpkSubParams *xsp);  /* a0 */
```

# Semantics

```c
xsp->xsp_OutLen = xsp->xsp_InLen;
CopyMem(xsp->xsp_InBuf, xsp->xsp_OutBuf, xsp->xsp_InLen);
return XPKERR_OK;   /* 0 */
```

Exec `CopyMem` (-624) is reached through the `xsb_SysBase` field stored
in the library base at init (not `4.w`).

# Notes

- No bounds check against `xsp_OutBufLen` — trusts the caller.
- Symmetry note: pack is refused ([XpksPackChunk](XpksPackChunk.md))
  but unpack is a memcpy — the stored format *is* the output format.
