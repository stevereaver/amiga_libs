---
type: Finding
title: New 44.x base fields
description: dataSize grew 0x2a -> 0x36; new fields are write-only inside the library.
---

# New 44.x base fields

Between the WB3.1-era builds (dataSize 0x2a) and WB3.5 (0x36) the
base gained three longs, all written once by LibInit and never read
by the library itself:

| offset | content |
|-------:|---------|
| 0x2a | self-pointer (the base address) |
| 0x2e | `0x11081999` — hardcoded date, 11.8.1999 |
| 0x32 | pointer to the hidden FindSemaphore probe |

`0x11081999` predates the 45.x builds' own ID-string dates
(13.11.2000, 25.4.2010) yet is unchanged there — it appears to be a
"born-on" signature of this code revision rather than a per-build
date.

These fields plus the probe pointer form a private extension API:
external software can verify the library's identity and invoke the
semaphore probe without any LVO.  See
[HiddenSemaphoreCheck](HiddenSemaphoreCheck.md).
