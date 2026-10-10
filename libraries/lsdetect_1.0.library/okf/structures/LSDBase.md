---
type: Structure
title: LSDBase
description: Private library base allocated by MakeLibrary (dataSize 0x44).
timestamp: 2026-10-10T20:40:00Z
---

# struct LSDBase — 0x44 bytes

| off | field |
|-----|-------|
| 0x00 | `struct Library` (34 bytes) |
| 0x22 | flag byte — bit 3 = deferred expunge |
| 0x23 | `BYTE` language cache (-1 = undetected) |
| 0x24 | `struct ExecBase *` SysBase |
| 0x28 | `struct Library *` GfxBase |
| 0x2c | `struct Library *` LowLevelBase |
| 0x30 | `struct Library *` LocaleBase |
| 0x34 | `struct Library *` DOSBase |
| 0x38 | `APTR` saved ActiView |
| 0x3c | `ULONG` saved colour 0 (packed nibbles) |
| 0x40 | `BPTR` seglist |
