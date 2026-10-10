---
type: Index
title: Functions
description: All 10 LVO entries (-6 .. -60), names per xpksub_lib.i.
---

# Functions

System vectors:

- [LibOpen](LibOpen.md) — LVO -6
- [LibClose](LibClose.md) — LVO -12
- [LibExpunge](LibExpunge.md) — LVO -18
- [LibNull](LibNull.md) — LVO -24, also shared by -42/-48/-60 (points at
  the `moveq #0/rts` entry stub in the original)

XPK sublibrary interface:

- [XpksPackerInfo](XpksPackerInfo.md) — LVO -30, returns `struct XpkInfo *`
- [XpksPackChunk](XpksPackChunk.md) — LVO -36, always `XPKERR_EXPANSION` (-17)
- XpksPackFree — LVO -42 → [LibNull](LibNull.md)
- XpksPackReset — LVO -48 → [LibNull](LibNull.md)
- [XpksUnpackChunk](XpksUnpackChunk.md) — LVO -54, CopyMem pass-through
- XpksUnpackFree — LVO -60 → [LibNull](LibNull.md)
