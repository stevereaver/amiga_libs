---
type: Finding
title: iff.library 23.2 findings
tags: [quirks]
timestamp: 2026-10-15T03:43:30Z
---

# iff.library 23.2 findings

- **Module entry prints a sign-on banner**: the hunk+0 entry
  OldOpenLibrary()'s dos.library, calls dos Output() (-60) then
  Write() (-48) of the 51-byte idstring, CloseLibrary()s dos, and
  returns 10. This runs when exec scans the resident, printing
  "IFF 23.2 (24.5.93) (-: by Christian A. Weber :-)\r\n" at boot.
- **datatab uses private opcodes** (0xa0 2-byte, 0x90 word, 0x80
  relocated-long) — worked because the binary predates newer
  InitStruct conventions; InitResident consumes it fine.
- Three reserved vectors (-102/-108/-114) share the -24 rts stub;
  -120 points at a separate bare rts at 0x1e0.
