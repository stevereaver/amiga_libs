---
type: Finding
title: Quirks
description: Repurposed Expunge vector and non-standard open counting.
timestamp: 2026-10-10T19:00:00Z
---

# Quirks

- The Expunge vector is the alert *trigger*, not an expunge.  Real
  teardown is deferred to Close when the private open count hits 0.
- Open increments a private word at base+0x38 and resets exec's
  `lib_OpenCnt` to 0 every time, so normal expunge accounting is
  bypassed entirely.
- RomTag version is 0 and lib_Version/lib_Revision are 0 — the
  library is unversioned; "0.0"/"10-Jun-87" exist only in file names
  and the idstring.
- The -24 vector aliases the module entry (`clr.l d0/rts`) instead
  of a dedicated stub.
- LVO -42 returns 1 with no side effects; no documented name.
