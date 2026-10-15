---
file: defects
---
# Findings

- Functab has a real NULL hole at index 3 (-24): oracle
  counts 12 entries including it; jump-area index maps
  cleanly.
- initfn stores a0 (seglist/SysBase-adjacent arg) at
  lib+0x22; normal.
- 4 invalid accesses (2x exec Remove on unlinked nodes) —
  deterministic, identical both sides.
