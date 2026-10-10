---
type: Finding
title: moveq #-1 module entry
description: Only this build returns -1 from the module entry point.
timestamp: 2026-10-10T19:00:00Z
---

# moveq #-1 module entry

This build's module entry is `moveq #-1,d0 / rts`; every other
version.library build examined (1.1, 33.1, 34.1 x2, 37.x, 38.36)
uses `moveq #0,d0`.  The value only matters when the file is run as
a program instead of being scanned as a resident module.  Reproduced
verbatim.
