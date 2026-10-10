---
type: Index
title: Functions
description: Exported functions and LVO entries analyzed for this library.
timestamp: 2026-10-10T19:00:00Z
---

# Functions

- [LibOpen](LibOpen.md) — LVO -6, bumps private open count, keeps lib_OpenCnt at 0.
- [LibClose](LibClose.md) — LVO -12, at count 0 removes the library and frees everything.
- [LibExpunge](LibExpunge.md) — LVO -18, the low-memory alert trigger; never expunges.
- [ModuleEntry](ModuleEntry.md) — LVO -24, reserved vector aliased to the module entry (`clr.l d0/rts`).
- [RegLowMemReq](RegLowMemReq.md) — LVO -30, registers port name + LowMemMsg.
- [DeRegLowMemReq](DeRegLowMemReq.md) — LVO -36, removes a registration by port name.
- [LMSQuery](LMSQuery.md) — LVO -42, undocumented probe, always returns 1.
