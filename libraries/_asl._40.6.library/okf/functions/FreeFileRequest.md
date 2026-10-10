---
type: Function
title: FreeFileRequest
description: Relay to asl.library LVO -36.
lvo: -36
registers: a0 = fileReq (pass-through)
timestamp: 2026-10-10T18:00:00Z
---

# `void FreeFileRequest(APTR fileReq __asm("a0"))`

**LVO -36** (code+0x110) — `moveq #-36,d1; bra RelayTail`

Relays to real asl.library `FreeFileRequest` (per `asl_lib.fd`).
See [RelayTail](RelayTail.md).
