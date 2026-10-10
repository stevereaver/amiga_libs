---
type: Index
title: Functions
description: Exported functions and LVO entries analyzed for this library.
---

# Functions

Function table (word offsets from 0x54):
`-1, 0050 0060 0076 00b4 00b8 00bc 00c0 00c4 00c8 00cc, -1, -1`.

- [LibOpen](LibOpen.md) — LVO -6
- [LibClose](LibClose.md) — LVO -12
- [LibExpunge](LibExpunge.md) — LVO -18
- [ExtFunc](ExtFunc.md) — LVO -24, `moveq #0,rts` stub
- [AllocFileRequest](AllocFileRequest.md) — LVO -30 relay
- [FreeFileRequest](FreeFileRequest.md) — LVO -36 relay
- [RequestFile](RequestFile.md) — LVO -42 relay
- [AllocAslRequest](AllocAslRequest.md) — LVO -48 relay
- [FreeAslRequest](FreeAslRequest.md) — LVO -54 relay
- [AslRequest](AslRequest.md) — LVO -60 relay
- [LibInit](LibInit.md) — InitTable init routine
- [RelayTail](RelayTail.md) — shared open/call/close dispatcher
