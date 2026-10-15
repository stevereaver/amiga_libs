---
type: Function
title: RequestFile
description: Relay to asl.library LVO -42.
lvo: -42
registers: a0 = fileReq (pass-through)
timestamp: 2026-10-10T18:00:00Z
---

# `LONG RequestFile(APTR fileReq __asm("a0"))`

**LVO -42** (code+0x114) — `moveq #-42,d1; bra RelayTail`

Relays to real asl.library `RequestFile` (per `asl_lib.fd`).
See [RelayTail](RelayTail.md).
