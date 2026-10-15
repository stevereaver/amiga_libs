---
type: Function
title: AllocFileRequest
description: Relay to asl.library LVO -30.
lvo: -30
registers: pass-through d0/a0/a1 → real asl.library AllocFileRequest()
timestamp: 2026-10-10T18:00:00Z
---

# `APTR AllocFileRequest(void)`

**LVO -30** (code+0x10c) — `moveq #-30,d1; bra RelayTail`

Name per NDK `asl_lib.fd` (`##bias 30` first entry).  All register
arguments pass through to the real asl.library function; return
value is the real function's d0 (0 if the open fails).  See
[RelayTail](RelayTail.md).
