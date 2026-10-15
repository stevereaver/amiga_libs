---
file: defects
---
# Findings

- Same code-gen family as 1.15 but the binary uses DREL16
  relocations (a `.o`-style delta-relocs tail) rather than RELOC32 —
  same family as the `rexxidentify_1.15_DIFF_` shipment, whose body
  was identical to 1.15 with the same alternate tail encoding.
- identify.library dependency bumped 39 -> 41 (matches identify
  41.x API additions).
- Close observed calling closelib on 4 dep bases + FreeMem 0x6c on
  expunge — matches 1.15.
