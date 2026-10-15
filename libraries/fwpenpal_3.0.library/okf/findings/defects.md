---
type: Findings
title: fwpenpal 3.0 quirks
---

# Findings / quirks

- Hunk tags are swapped: the main hunk carrying resident+code
  is tagged 0x3ea DATA; the small auxiliary block is 0x3e9
  CODE.  Cross-hunk reach via `jmp abs` trampoline.
- Open returns the library base and bumps opencnt; two opens
  then two closes underflow opencnt to 0xffff before the
  deferred-expunge path runs.
- 5-entry functab — the -24 "reserved" slot points at the
  h0+0 stub rather than a real function.
