---
file: defects
---
# Findings

- Dep strings dos/intuition/graphics.library are inline
  in the CODE hunk between InitTable and code.
- Runtime: ~5.06M invalid accesses counted — the crunch
  core walks raw buffers; deterministic (identical count
  on rebuild).
- BSS hunk is only 16 bytes (global pointers).
