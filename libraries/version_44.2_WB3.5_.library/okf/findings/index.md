---
type: Index
title: Findings
description: Quirks, open questions, and reconstruction deviations for version.library 44.2.
---

# Findings

- [CloseSemantics](CloseSemantics.md) — Expunge is a stub; Close
  always frees the library at OpenCnt==0; no LIBF_DELEXP handling.
- [HiddenSemaphoreCheck](HiddenSemaphoreCheck.md) — LibInit plants
  a FindSemaphore probe pointer in the extended base; obfuscated
  name decodes to « IPrefs » with key 0xE9.
- [BaseFields](BaseFields.md) — the 44.x-only base fields
  (self-pointer, hardcoded 0x11081999 date, probe pointer).
- [RebuildDeviations](RebuildDeviations.md) — where the rebuilt
  binary differs from the original.
