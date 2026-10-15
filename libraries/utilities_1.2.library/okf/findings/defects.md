---
type: Findings
title: utilities 1.2 quirks
---

# Findings / quirks

- Resident lives at the END of the DATA hunk (h1+0x3bc) — an
  unusual resident-in-data placement.
- -24 reserved vector points at hunk0 start (the bra/stub).
- One vector's deferred-expunge tail frees a NULL pointer
  (freemem D0=0) under stubs.
- All message strings are Polish — a localization-build library.
