---
file: defects
---
# Findings

- Identical binary ships as both diskfont_34.37.library
  and diskfont_34.37_WB1.3_.library (same md5
  96c61981db9d358f7864a044e9ec794e) — one reconstruction
  serves both.
- libInit returns 0 under stubs (exec -552 probe) but
  library stays installed.
- 164 invalid accesses during vector probing —
  deterministic, counted identically on both binaries.
