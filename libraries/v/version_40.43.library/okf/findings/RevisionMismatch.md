---
type: Finding
title: Revision mismatch
description: ID string claims "version 40.43" but LibInit stamps lib_Revision = 42.
---

# Revision mismatch

The binary's ID string reads `version 40.43 (07.2.11)` and its
filename is `version_40.43.library`, yet the init routine writes
`move.w #$002a, 22(a5)` — **lib_Revision = 42**, not 43.

Evidence: text+0x6e in the shipped binary:

```
3b7c 002a 0016    move.w #$002a,$16(a5)   ; lib_Revision = 42
```

This looks like a rebuild that bumped the ID string but not the
revision constant (or vice versa).  The unusual date format
"(07.2.11)" — zero-padded day, two-digit year, unlike Commodore's
"(18.2.94)" style — suggests a post-Commodore/community rebuild.

Practical effect: `OpenLibrary("version.library", ...)` reports
`lib_Version = 40, lib_Revision = 42` while `$VER:` scanning or the
Version command reports "40.43".

The reconstruction faithfully reproduces the quirk
(`source/version.c` writes `lib_Revision = 42`).
