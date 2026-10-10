---
type: Structure
title: G3Context
description: Inferred layout of the external structure g3 points at.
timestamp: 2026-10-10T20:20:00Z
---

# struct G3Context — inferred

Only the offsets touched by the vectors are known:

| off | use |
|-----|-----|
| +12 | function pointer — tail-called by LVO -66 |
| +100 | function pointer — called with a1=buffer by LVO -96 |
| +104 | STRPTR — copied to buffer by LVO -102 |
| +108 | STRPTR — copied to buffer by LVO -108 |
| +112 | ptr — longword at ptr-2 returned by LVO -114 |
| +116 | ptr — longword at ptr-2 returned by LVO -120 |

The -2 reads suggest the pointers target structures whose first
word is a header/type field, e.g. reading a length or type word
located just before the pointed data.
