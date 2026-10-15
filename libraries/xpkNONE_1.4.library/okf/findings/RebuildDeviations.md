---
type: Finding
title: Rebuild deviations
timestamp: 2026-10-10T19:45:00Z
---

# Rebuild deviations

**None** — the verbatim assembly rebuild (`xpkNONE_v.s`) is
byte-identical to the shipped binary, including:

- the scrambled, non-monotonic 28-entry RELOC32 tail (island pointers
  0x1ea..0x1b6 first, then functab/RomTag/InitTable/datatab entries
  interleaved) — `fixup.py` rewrites GNU ld's ascending list verbatim;
- rt_EndSkip = +0x9e pointing at the name string, mid-resident;
- the dead `bsr` to the null stub in LibInit (InitStubCall.md);
- the missing `$VER:` cookie and `\r\n` line ending.

Historical note: the earlier C model (`make cmodel`) was identical
only through the header region (0x260-byte hunk, gcc codegen order,
folded dead call).
