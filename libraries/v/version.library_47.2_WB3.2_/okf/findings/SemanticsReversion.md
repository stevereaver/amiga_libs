---
type: Finding
title: 47.x semantics reversion
description: The WB3.2.x version.library line returns to textbook DELEXP semantics.
timestamp: 2026-10-10T21:55:00Z
---

# 47.x semantics reversion

version.library has no public API — its only observable behavior
is how Open/Close/Expunge manage the library's lifetime, and
that has drifted across generations:

| builds | Open | Close at opcnt 0 | Expunge (-18) | base size |
|---|---|---|---|---|
| 1.1–38.x | opcnt++ | unconditional expunge | unconditional expunge | 0x2a |
| 39.x–40.x | opcnt++ | unconditional expunge | **null stub** | 0x2a |
| 44.x–45.x | opcnt++ | unconditional expunge | **null stub** | 0x36 (+hidden probe) |
| **47.2/47.3 (WB3.2.x)** | opcnt++, **clears DELEXP** | expunge **only if DELEXP** | **real routine** (mark-or-expunge) | 0x2a |

The 47.x build is the only generation implementing the textbook
`LIBF_DELEXP` contract.  Since version.library is normally never
expunged (ROM/startup resident), the difference is latent, but
the code path is observably different from every prior shipped
build — filed as a cross-version inconsistency.
