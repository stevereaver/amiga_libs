---
type: Structure
title: FWFilterBase
description: Private library base, 0x28 bytes (struct Library + SegList).
resource: source/fwbase.h
timestamp: 2026-10-10T19:15:00Z
---

# FWFilterBase

InitTable `dataSize` is 0x28 (40): `struct Library` (34 bytes) plus a
single private pointer. `lib_OpenCnt` (offset 0x20) lives inside the
standard base. There is no SysBase field — Expunge reads `4.w`.

| offset | field | notes |
|-------:|-------|-------|
| 0x00   | `struct Library fb_Lib` | standard 34 bytes |
| 0x22   | pad | unused, keeps 0x24 long-aligned |
| 0x24   | `BPTR fb_SegList` | stored by LibInit (a0), returned by Expunge |
