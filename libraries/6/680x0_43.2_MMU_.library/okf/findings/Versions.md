---
type: Finding
title: Differences vs other 680x0.library builds
description: What changed between the 40.4, 46.1 and 47.2 binaries.
timestamp: 2026-10-10T18:00:00Z
---

# Version differences (vs 47.2)

This 40.4 build lacks the 47.2 additions:

- no Apollo/AC68080 detection - the supervisor probe only reports
  whether `movec pcr` traps, so any PCR-capable core is '6'.
- `OpenCPUDriver` has no `cpu > '9'` guard and no (dead)
  `"apollo.library"` string in the data hunk.
- the driver library is opened with minimum version 40
  (47.2 uses 46); SetFPUExceptions still checks the driver for
  `lib_Version >= 40` itself.
- id string: `"680x0.library 40.4 (25.11.2001) (c) 1999,2001 The MMU.lib
  development group, THOR"`.

Identical-code siblings in this repo: the 40.4 and "43.2(MMU)"
binaries are byte-identical, as are 46.1 and "46.3(MMU)" - the
version numbers in those file names do not match the embedded
$VER/lib_Version.
