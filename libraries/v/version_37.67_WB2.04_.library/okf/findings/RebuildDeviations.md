---
type: Finding
title: Rebuild deviations
description: What differs between the original binary and the C reconstruction.
timestamp: 2026-10-10T19:00:00Z
---

# Rebuild deviations

* **Hunk count.** The original file carries a second, empty
  (zero-length) code hunk after hunk 0.  The m68k-amigaos-ld output
  has a single code hunk -- the toolchain does not emit empty hunks.
  Functionally irrelevant.
* **Code generation.** GCC emits a6 save/restore around the vector
  entry points (a6 is callee-saved in the C ABI but is the library
  base register for LVO calls), so the compiled functions are a few
  bytes longer than the originals.  Semantics verified instruction
  by instruction against the IRA disassembly.
* **Table regions byte-identical.** RomTag, name/id strings,
  InitTable, function table contents and InitStruct bytes (including
  the documented quirks) reproduce exactly; all 14 RELOC32 slots
  match the original's relocation set by purpose.
