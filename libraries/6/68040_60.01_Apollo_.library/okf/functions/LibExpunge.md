---
type: Function
title: LibExpunge
description: Null stub returning 0; serves LVO -18 and LVO -24 (ExtFunc).
lvo: -18
registers: d0 = 0 (out)
---

# `LONG LibExpunge(void)`

**LVO -18** (and **LVO -24** — the function table lists this address
twice: Expunge and ExtFunc share one `moveq #0,d0/rts` stub).

The library can never be expunged; combined with LibClose's missing
decrement-free path this keeps the stub permanently resident.
