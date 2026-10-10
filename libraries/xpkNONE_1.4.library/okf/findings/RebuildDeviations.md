---
type: Finding
title: Rebuild deviations
timestamp: 2026-10-10T19:45:00Z
---

# Rebuild deviations

The rebuilt `source/xpkNONE.library` is not byte-identical (expected):

- Code hunk 0x260 bytes vs original 0x288 (gcc codegen).
- Function code order differs; function-table *order* matches.
- The dead `bsr` to the null stub in LibInit is folded away by gcc
  (documented in InitStubCall.md).
- XpksUnpackChunk avoids the original's redundant InLen reload.

Byte-identical through the whole header region (entry opcode, 10-entry
function-table shape, padding, all InitStruct bytes, InitTable fields,
RomTag fields, name and id strings including the missing `$VER:`
cookie and the `\r\n` line ending).
