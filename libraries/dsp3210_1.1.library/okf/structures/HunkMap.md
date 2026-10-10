---
type: Structure
title: HunkMap
description: Single code hunk, 0x43c bytes, non-AUTOINIT RomTag.
timestamp: 2026-10-10T20:10:00Z
---

# Hunk map

One code hunk (0x10f longs = 0x43c bytes) + RELOC32 + END. The RomTag
has `rt_Flags` = 0 — this module is NOT autoinit; rt_Init points at
bootstrap code.

| .text off | content |
|-----------|---------|
| 0x00 | `moveq #0,d0 / rts` entry |
| 0x04 | RomTag (endskip +0x43a, init +0x56) |
| 0x1e | "dsp3210.library\0" |
| 0x2e | "$VER: " cookie bytes |
| 0x34 | "dsp3210.library 1.1 (3.1.2020)\0" (idstring) |
| 0x56 | ResidentInit (MakeLibrary -84, AddLibrary -396) |
| ~0x76 | InitBase (manual field init) |
| ~0xa8 | LibOpen / LibClose / LibExpunge / LibNull |
| ~0xec | function table (6 longs + -1L) |
| ~0x10a | DSPCalcLen + BE-read helpers |
| ~0x180 | DSPRelocate (+ strcmp helper) |
| 0x43a | endskip / pad |
