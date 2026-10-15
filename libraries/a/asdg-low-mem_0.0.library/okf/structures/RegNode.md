---
type: Structure
title: RegNode
description: 20-byte client registration node.
timestamp: 2026-10-10T19:00:00Z
---

# struct RegNode — 20 bytes

| off | field |
|-----|-------|
| 0 | `struct Node` — ln_Succ/ln_Pred used for the list; ln_Type and ln_Pri cleared, ln_Name = private copy of the port name |
| 14 | `struct Message *` client's LowMemMsg |
| 18 | `UWORD` allocation size of the name copy |

Freed by DeRegLowMemReq and by Close draining the list.
