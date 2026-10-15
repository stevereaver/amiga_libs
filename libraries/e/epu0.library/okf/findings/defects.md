---
file: defects
---
# Findings

- 7-hunk granularity for a 4KB library (4 CODE + 2 DATA +
  declared BSS) — per-module link order preserved verbatim.
- BSS hunk declared size must be emitted verbatim (a naive
  resplit emits 0).
- close-underflow path: opencnt reads 0xffff after 2 closes
  at cnt=0 — the lib's own flag word drives it.
