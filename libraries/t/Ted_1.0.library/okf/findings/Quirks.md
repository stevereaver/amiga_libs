---
type: Finding
title: Quirks
description: Oddities found in the shipped binary.
timestamp: 2026-10-10T20:20:00Z
---

# Quirks

- `dos.library` is opened at init and closed at expunge but never
  called — a dead dependency.
- The deferred-expunge flag is bit 3 of the private byte at
  base+34, not `lib_Flags` (offset 14) — mimics LIBF_DELEXP in
  private space.
- InitFunc never checks the OpenLibrary result — a missing dos
  base would still init "successfully".
- All sixteen user functions are stubs/getters around five
  code-hunk longs plus a scratch string buffer; the real logic
  lives in whatever structure clients point g3 at — purpose
  inferred, not documented.
