---
type: Finding
title: Rebuild deviations
description: Byte-level differences between the original and the C rebuild.
timestamp: 2026-10-10T09:40:00Z
---

# Rebuild deviations

Rebuild (`make` in `source/`): sha256
`24c656692a245f452d1a42ad956046043c36ab672af910c0a59de7f4d1141027`,
.text 0x368 bytes vs. the original 0x278 (gcc codegen is larger than
the hand-rolled 68020 asm encoder).

- Identical: entry stub, RomTag matchword/matchtag/flags/version/
  type/pri, RT_ENDSKIP semantics (module end — an `endmodule.o` linked
  last makes `_endcode` land there), InitStruct data bytes, table
  order, all strings, XpkInfo/XpkMode contents.
- Different: internal block ordering (InitTable/datatab/strings/
  descriptors all precede functab+code in the rebuild; the original
  interleaves functab and strings with the code up front and
  descriptors at the end), all code offsets, and the compiled
  function bodies (semantics preserved: the encoder's read-ahead,
  the 4+pend reserve check, the 0x80 decode case and the missing
  output bounds are all reproduced).
- Reserved slots point at a distinct `_LibNull`, as in the original.
