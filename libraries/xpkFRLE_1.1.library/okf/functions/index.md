---
type: Index
title: Functions
description: Exported functions and LVO entries analyzed for this library.
timestamp: 2026-10-10T22:45:00Z
---

# Functions

## System vectors

- [LibOpen](LibOpen.md) — LVO -6.
- [LibClose](LibClose.md) — LVO -12.
- [LibExpunge](LibExpunge.md) — LVO -18.
- [ExtFunc](ExtFunc.md) — LVO -24 → shared `moveq #0,d0` stub.

## XpksSub vectors

- [XpksPackerInfo](XpksPackerInfo.md) — LVO -30, returns XpkInfo block.
- [XpksPackChunk](XpksPackChunk.md) — LVO -36, FRLE encoder.
- [XpksPackFree](XpksPackFree.md) — LVO -42 → null stub.
- [XpksPackReset](XpksPackReset.md) — LVO -48 → null stub.
- [XpksUnpackChunk](XpksUnpackChunk.md) — LVO -54, FRLE decoder.
- [XpksUnpackFree](XpksUnpackFree.md) — LVO -60 → null stub.
