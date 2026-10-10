---
type: Structure
title: MathTransBase
description: Private library base, 0x2c bytes.
---

# MathTransBase — InitTable dataSize 0x2c

| off  | field              | note                          |
|------|--------------------|-------------------------------|
| 0x00 | struct Library     | lib_Node/lib_Flags/OpenCnt... |
| 0x22 | SysBase            | saved by init (entry a6)      |
| 0x26 | SegList            | saved by init (entry a0)      |
| 0x2a | private flags byte | bit3 = DELEXP                 |
| 0x2b | pad                |                               |

The private flag byte — not `lib_Flags` — carries the
deferred-expunge state, same convention as the sibling
mathieeesingtrans/mathieeedoubbas 40.6 builds.

`source/mtbase.h` — `struct MTBase`.
