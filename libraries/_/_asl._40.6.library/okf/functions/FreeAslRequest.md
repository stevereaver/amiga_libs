---
type: Function
title: FreeAslRequest
description: Relay to asl.library LVO -54.
lvo: -54
registers: a0 = requester (pass-through)
timestamp: 2026-10-10T18:00:00Z
---

# `void FreeAslRequest(APTR requester __asm("a0"))`

**LVO -54** (code+0x11c) — `moveq #-54,d1; bra RelayTail`

Relays to real asl.library `FreeAslRequest` (per `asl_lib.fd`).
See [RelayTail](RelayTail.md).
