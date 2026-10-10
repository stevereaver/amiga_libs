---
type: Finding
title: Rebuild deviations
timestamp: 2026-10-10T19:15:00Z
---

# Rebuild deviations

The rebuilt `source/fwfiltertype.library` is not byte-identical to the
original (expected — different compiler):

- Code hunk 0x194 bytes vs original 0x1b4 (gcc codegen).
- The dead `cmpi.w #$4294,d0` is absent (documented in DeadCompare.md).
- LibOpen keeps a6 on the stack briefly (gcc prologue) where the
  original used a6 directly; semantics identical.

Byte-identical: RomTag fields, module-entry opcode, name string,
$VER/copyright strings, InitTable field layout (dataSize 0x28), all
InitStruct command bytes, function-table entry count/order including
the shared LibNull address for -24/-36, and -1L terminator.
