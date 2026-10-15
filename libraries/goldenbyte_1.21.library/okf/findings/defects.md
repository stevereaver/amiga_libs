---
type: Findings
title: goldenbyte.library 1.21 quirks
---

# Findings / quirks

- idstring has no '$VER:' marker — just 'GOLDEN BYTE 1.21
  (24.02.97)' + CRLF.
- Resident version field is 1 (binary named 1.21 — rev in
  filename only).
- initfn returns a library-base-ish value (not the lib pointer)
  — observed identical on both binaries.
- 47-entry single RELOC32 group in mixed order.
