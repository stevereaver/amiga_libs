---
file: defects
---
# Findings

- Resident ver=0 while filename says 0.5; id string has
  no $VER: prefix (just name + date + author).
- Vectors read memory at negative absolute addresses
  (0xfffffffc region) — relies on negative-offset lib
  fields being walked past LIB base.
- 1827 invalid accesses under oracle, deterministic.
