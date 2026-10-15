---
type: Function
title: XpksUnpackChunk
description: Stored chunks unpack by a plain CopyMem.
lvo: -54
timestamp: 2026-10-10T09:20:00Z
---

# Signature

```c
LONG XpksUnpackChunk(struct XpkSubParams *xsp /* a0 */,
                     struct XpkSubBase *base /* a6 */);  /* -> d0 */
```

# Semantics

Pushes a6, then: `xsp_OutLen = xsp_InLen` (InLen @4 → OutLen @16),
`a1 = xsp_OutBuf`, `a0 = xsp_InBuf`, `a6 = *(4).w` (ExecBase),
`jsr -624(a6)` (CopyMem), `moveq #0,d0`, pop a6, rts. Returns
`XPKERR_OK`. `xsp_OutBufLen` is not checked against InLen — the master
is trusted to size the buffer. .text+0x11c.
