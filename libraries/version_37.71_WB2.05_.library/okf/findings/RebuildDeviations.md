---
type: Finding
title: Rebuild deviations (historical)
description: >-
  Deviations of the earlier C reconstruction.  SUPERSEDED:
  source/version.s + fixup.py now rebuilds the file byte-identically
  (md5 cd11aaabbbfd0cb23eae59edf16d321b).
timestamp: 2026-10-10T19:00:00Z
---

# Rebuild deviations (C model — superseded)

The current canonical build is `source/version.s` + `source/fixup.py`,
byte-identical to the shipped binary including the empty second CODE
hunk record and the descending RELOC32 order.  The notes below applied
to the earlier C reconstruction (`make cmodel`):

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
  InitTable, function table contents and InitStruct bytes reproduce
  exactly; all 14 RELOC32 slots match the original's relocation set.
