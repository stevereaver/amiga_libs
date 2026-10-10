---
type: Function
title: OpenClipboard
description: AllocVec(120,0).
lvo: -246
registers: d0
timestamp: 2026-10-10T18:00:00Z
---

# `struct ClipboardHandle *OpenClipboard(unit)`

**LVO -246** — registers `d0`

AllocVec(120,0); two AllocSignal(-1); inits CBport+SatisfyPort MsgPorts; OpenDevice("clipboard.device",unit,...). Fail -> partial CloseClipboard + NULL.
