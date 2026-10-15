---
file: defects
---
# Findings

- initfn succeeds under stubs (lib=100000, seglist unused
  =0) — self-contained 1991 build.
- -30 vector's returned table is not an XpkPackerInfo
  despite overlapping ABI slots; calls are deterministic.
- All 11 vectors execute cleanly under the generic harness
  (no invalid accesses logged).
