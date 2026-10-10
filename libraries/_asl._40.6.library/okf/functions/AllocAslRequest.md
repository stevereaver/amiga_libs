---
type: Function
title: AllocAslRequest
description: Relay to asl.library LVO -48.
lvo: -48
registers: d0 = reqType, a0 = tagList (pass-through)
timestamp: 2026-10-10T18:00:00Z
---

# `APTR AllocAslRequest(ULONG reqType __asm("d0"), struct TagItem *tagList __asm("a0"))`

**LVO -48** (code+0x118) — `moveq #-48,d1; bra RelayTail`

Relays to real asl.library `AllocAslRequest` (per `asl_lib.fd`).
See [RelayTail](RelayTail.md).
