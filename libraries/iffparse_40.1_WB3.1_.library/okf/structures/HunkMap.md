---
type: Structure
title: Hunk map
description: Binary layout of iffparse_40.1(WB3.1).library (6832 bytes).
timestamp: 2026-10-10T18:00:00Z
---

# Hunk map

Two hunks: code `.text` 0x1974 (file offset 0x24), data `.data`
0x8c (file offset 0x19f4).  Both carry REL32 relocations.

## .text layout

| offset | contents |
|-------:|----------|
| 0x00 | `moveq #-1,d0 / rts` (executable-entry return) |
| 0x04 | Resident: `4afc`, MatchTag, EndSkip=0x1964, flags 0x80 (AUTOINIT), version 40, NT_LIBRARY |
| 0x1e | `"iffparse.library"` |
| 0x2f | `"iffparse 40.1 (9.2.93)\r\n"` |
| 0x48 | InitTable: dataSize 0x44, functab 0x58, dataTable 0, init 0xb6 |
| 0x58 | function table: `dc.w -1`, 45 word offsets, `dc.w -1` |
| 0xb6 | LibInit (OpenLibrary dos/utility v37, cache vectors) |
| 0x146 | LibOpen, 0x154 LibClose, 0x174-ish expunge path |
| 0x162 | shared `moveq #0,rts` stub → LVO -24 and -96 |
| 0x1be | close-both-libs helper used by init fail path |
| 0x1964 | shared MinList-init subroutine (3 insns + rts) |
| 0x194c-0x1963 | 4 math trampolines through cached utility slots |

## .data layout (7 × 20-byte Hook objects)

| offset | h_Entry | role |
|-------:|--------:|------|
| +0x00 | 0xa7c | property chunk handler |
| +0x14 | 0x270 | stop handler → IFF_RETURN2CLIENT (-12) |
| +0x28 | 0xb14 | collection handler |
| +0x3c | 0x26c | stop-on-exit handler → IFFERR_EOC (-2) |
| +0x50 | 0xc5e | collection purge hook |
| +0x64 | 0xefa | DOS stream hook |
| +0x78 | 0x10ca | clipboard stream hook |

Each object is exactly `struct Hook`; the code pointer sits at +8
= `h_Entry`, the standard hook dispatch field.  See
[Handlers.md](Handlers.md).
