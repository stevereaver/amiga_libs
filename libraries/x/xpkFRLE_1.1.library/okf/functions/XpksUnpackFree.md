---
type: Function
title: XpksUnpackFree
description: Unimplemented sublib slot — shares the null stub.
lvo: -60
registers: -> d0 0
timestamp: 2026-10-10T22:45:00Z
---

# XpksUnpackFree

**LVO -60**

The functab entry points at the shared `moveq #0,d0; rts` stub —
the slot is declared in the XpksSub API but this packer keeps no
per-pack state, so there is nothing to free or reset.
