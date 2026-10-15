---
file: defects
---
# Findings

- Resident flags 0x81 (AUTOINIT|bit0) — unusual extra bit.
- 3 zero-length CODE hunks (h15/h16) + zero-length DATA h18 —
  per-function linker artifacts like WB1.0's mathtrans 1.3.
- Deterministic unmapped reads (0xffffff2e..0xfffffffe) in a
  vector path under stub emulation — firmware walks a table.
