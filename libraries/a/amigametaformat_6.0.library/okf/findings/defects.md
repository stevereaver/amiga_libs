---
type: Findings
title: amigametaformat 6.0 quirks
---

# Findings / quirks

- idstring lacks '$VER:' marker — 'AmigaMetaFormat AMF(tm) 6.0'
  with '(tm)' literal, no version-number prefix.
- Open returns 0 when AMF/* drivers can't LoadSeg (stub env) —
  graceful failure rather than self-expunge.
- 12 driver-path strings, 'strip.driver' listed 3x (index
  table maps different format IDs to the same driver).
- Close vector always closes the 3 opened libs + frees 0x5dc
  bytes — runs even when open count >0 (deferred-expunge path).
