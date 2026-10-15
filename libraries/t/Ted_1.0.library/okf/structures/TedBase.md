---
type: Structure
title: TedBase
description: Private library base allocated by MakeLibrary (dataSize 0x30).
timestamp: 2026-10-10T20:20:00Z
---

# struct TedBase — 0x30 bytes

| off | field |
|-----|-------|
| 0x00 | `struct Library` (34 bytes) |
| 0x22 | private flag byte — bit 3 = deferred expunge |
| 0x24 | `struct ExecBase *` SysBase |
| 0x28 | `struct Library *` DOSBase (opened v0, never used) |
| 0x2c | `BPTR` seglist |
