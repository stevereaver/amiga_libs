---
type: Finding
title: Rebuild deviations
description: Byte-level differences between the original and the C rebuild.
timestamp: 2026-10-10T09:20:00Z
---

# Rebuild deviations

Rebuild (`make` in `source/`): sha256
`536263c9b9b95b725155516bace33f7780409ea98c7fdc7cb4b6e4af2fd13b8c`,
.text 0x230 bytes vs. the original 0x20c.

- Bytes 0x00–0x67 are identical: entry stub, RomTag, both strings,
  dataSize and InitStruct data all match.
- Object link order differs: the rebuild places the XpkInfo/XpkMode
  block and strings (from `xpkNONE_lib.o`) ahead of the generated
  functab and C code; the original has functab → code → descriptors →
  strings. All block *contents* match field-for-field.
- LibInit is byte-identical (`2240 23480022 4e75` — nice win).
- The remaining functions implement identical semantics with gcc
  codegen (a6 save/restore, btst→branch instead of fallthrough in
  Close, or.b for flag clear in Open). Vector order in the table is
  the same; reserved slots point at a distinct `_LibNull` rather than
  the entry stub.
- No data/bss hunks in either image.
