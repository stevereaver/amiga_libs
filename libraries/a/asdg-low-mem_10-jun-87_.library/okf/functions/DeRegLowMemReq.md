---
type: Function
title: DeRegLowMemReq
description: Remove a client registration by port name.
lvo: -36
registers: a0 portname, a6 base
timestamp: 2026-10-10T19:00:00Z
---

# ``LONG DeRegLowMemReq(STRPTR portName)``

**LVO -36** — `a0` = NUL-terminated port name

`FindName()` the client list; if found `Remove()` the node and free
its name string + 20-byte node.  Always returns 0, even when the
name was not registered.
