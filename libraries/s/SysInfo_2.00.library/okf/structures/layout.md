---
type: Structures
title: SysInfo.library 2.00 layout
---

# Layout

- datasize 0x4c -> 34-byte Library node + 76 private bytes.
- Private region holds seglist + bases for the
  'Executive_server' msg-port machinery.
- hunk1+0 is an unused zero long; the InitTable starts at h1+4
  (the resident rt_Init relocates to h1+4, not h1+0).
- hunk1+0x14 is a fifth relocated long -> h0+0x1fa, pointing one
  byte past the '$' of the '$VER:' string — likely the InitTable
  tail's stray extension or a deliberate idstring-1 pointer.
