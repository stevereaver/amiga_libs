---
type: Findings
title: sz_aio_ahi 0.2 quirks
---

# Findings / quirks

- idstring lacks '$VER:' marker — 'sz_aio_ahi V0.2  09.03.2000  by Rainer Muller'
  with '(tm)' literal, no version-number prefix.
- Open returns 0 when ahi.device can't be opened (stub env) —
  graceful failure rather than self-expunge.
- Close vector always closes the 3 opened libs + frees 0x5dc
  bytes — runs even when open count >0 (deferred-expunge path).
- Same codegen skeleton as amigametaformat.library (dsz 0x430,
  InitStruct datatab@+0x2e) — shared build template.
- Resident version field is 0 despite the 'V0.2' idstring and
  filename — version never initialized in the RomTag.
