---
type: Structure
title: FreeAnimBase (library base)
description: Library base layout, 0x2a bytes — Library plus two unused longs.
timestamp: 2026-10-10T18:00:00Z
---

# FreeAnimBase

InitTable `dataSize` = 0x2a: `struct Library` (34 bytes, 0x00-0x21)
plus 8 extra bytes (0x22-0x29) that are never touched — the library
has no code that stores into its base at all (init is the shared
null stub, so no segment list is saved either).

| offset | field | evidence |
|-------:|-------|----------|
| 0x00 | `struct Library` | InitStruct absent → all zeroed except exec-filled header fields |
| 0x22 | 2 × `ULONG` unused | within dataSize 0x2a; never referenced |
