---
type: Finding
title: Quirks
description: Oddities found in the shipped binary.
timestamp: 2026-10-10T21:10:00Z
---

# Quirks

- **RomTag version lie + self-patch**: `rt_Version` is **2** and
  init writes `lib_Revision = 2`, although file and IdString
  advertise 45.2 — same trick as the 45.1 original, but this
  build *also* patches the RomTag `RT_VERSION` byte with 2 at
  runtime (self-modifying write into the data hunk).
- **NULL-base CloseLibrary**: on init failure `CloseLibs` calls
  `CloseLibrary` on all three support-base slots
  unconditionally, including NULL ones — a crash path preserved
  verbatim.
- **68000-illegal opcode**: the WBStart tag loop tests the
  `NextTagItem` result with `tst.l a0` (0x4a88) — not a valid
  plain-68000 instruction (68020+).  The library is marked for
  any CPU but will fault on a stock 68000.
- **Inverted result**: WBStart returns **0** on success and
  **20** (RETURN_ERROR) on any failure, including a missing name
  tag — matching 45.1's convention, inverting the workbench BOOL.
- **Dead code**: the code hunk ends with two libc-style string
  routines (strcat/strcpy shapes) that are never called —
  compiler runtime pulled in but unused.
- **Module entry returns -1** — not loadable as a program.
- **NULL-safe calls relied on**: `FreeVec(NULL)`, `UnLock(0)` are
  invoked unconditionally.
