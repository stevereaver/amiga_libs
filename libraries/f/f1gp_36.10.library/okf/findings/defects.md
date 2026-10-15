---
file: defects
---
# Findings

- h1 header alloc (0x76 longs) vs hunk-tag size (0x22 longs)
  mismatch: reserved space with no file data — preserved.
- h1 body is embedded PowerPC code, not 68k data — WarpOS-era
  hybrid; the 68k side installs/forwards it.
- -48 returns constant 0xffffe6ce (looks like an address/value
  leak rather than a meaningful result).
- RELOC32 second group lists ->h1 offsets in descending order.
