---
type: Function
title: AslRequest
description: Relay to asl.library LVO -60.
lvo: -60
registers: a0 = requester, a1 = tagList (pass-through)
timestamp: 2026-10-10T18:00:00Z
---

# `LONG AslRequest(APTR requester __asm("a0"), struct TagItem *tagList __asm("a1"))`

**LVO -60** (code+0x120) — `moveq #-60,d1; bra RelayTail`

Relays to real asl.library `AslRequest` (per `asl_lib.fd`).
See [RelayTail](RelayTail.md).
