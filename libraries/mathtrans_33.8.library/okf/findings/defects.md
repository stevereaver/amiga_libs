---
file: defects
---
# Findings

- Flags 0x81 (AUTOINIT + bit0) as in 31.2.
- Zero-length h13/h14 CODE + zero-length trailing DATA hunk.
- Shipped twice in the collection: mathtrans_33.8.library and
  mathtrans_33.8(WB1.2+).library are md5-identical.
- Deterministic unmapped reads in one vector path under
  stub emulation.
