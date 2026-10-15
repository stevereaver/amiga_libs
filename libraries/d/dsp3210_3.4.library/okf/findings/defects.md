---
file: defects
---
# Findings

- Absolute-long functab vs word-offset in 4.0+/5.0/6.0 — the
  3.x line predates the compact table format.
- DSPRelocate returns -3 (odd-renumbered error set shared
  with 5.0/6.0, unlike 4.0's even set).
- -60/-72 return -1; -66 returns a handle-like value.
- Reserved -24 vector present as real code (0x16e) unlike the
  literal-0 holes in some siblings.
