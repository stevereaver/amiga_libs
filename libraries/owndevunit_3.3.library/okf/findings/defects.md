---
file: defects
---
# Findings

- h0 hunk record declares 0x4e longs but the file physically
  carries 0x4f — an extra `moveal sp@+,a0; rts` long sits
  between the declared body end and the RELOC32 tail. A real
  LoadSeg would misparse this; preserved verbatim.
- h1 DATA: hunk-table alloc (0x53) exceeds record body (0x41).
- Same family of alloc/body quirks as wbstart_2.x but on the
  CODE hunk in the OPPOSITE direction (file > declared).
