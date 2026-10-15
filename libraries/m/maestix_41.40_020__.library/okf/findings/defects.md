# Findings & defects

- DREL16 relocation format (word offsets).
- Close underflows open count (65534).
- initfn uses exec -558 (AllocateSignal-style) directly on the
  segment pointer; returns 0 under stubs.
- ~7 deterministic invalid reads at functab edge.
