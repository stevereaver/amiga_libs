---
type: Function
title: LibClose
description: Null stub shared by LVO -12, -18 and -24.
lvo: -12
registers: d0 = 0 (out)
---

# `LONG LibClose(void)`

**LVO -12** — and the same address is used for **LVO -18** (Expunge)
and **LVO -24** (ExtFunc): `moveq #0,d0/rts`.

OpenCnt is never decremented → the library can never be expunged
(deliberate keep-resident leak, matching the "loader stub" design).
