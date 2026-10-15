---
file: defects
---
# Findings

- rt_Version = 0 in the Resident while the idstr claims 37.3 —
  exec-reported version is 0.
- Plain-resident (flags 0) but rt_Init is a one-call thunk to the
  real init; the functab sits in a separate DATA hunk behind the
  lib node fields.
- One functab entry is a literal 0 (not the usual ->h0+0 stub).
