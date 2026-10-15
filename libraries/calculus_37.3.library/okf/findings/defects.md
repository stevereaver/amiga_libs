---
file: defects
---
# Findings

- Resident version field is 1 while the id string claims
  37.3 — rt_Version never carried the real version; exec
  reports lib ver 1 unless initfn overwrites it.
- initfn has a dead version-check preamble (two jsr's into
  moveq stubs that always return 0/1) before the real init.
- Functab has only 5 entries — tiny API surface for a
  "calculus" lib; most of the binary is the worker + data
  tables (h1 carries a (ptr,tag) pair table).
