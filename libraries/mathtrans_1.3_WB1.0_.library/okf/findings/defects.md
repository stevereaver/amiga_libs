---
type: Findings
title: mathtrans 1.3 quirks
---

# Findings / quirks

- Functab is 2-byte aligned (h0+0x7a) — long entries at odd
  word boundary.
- hunk14 and hunk16 are zero-length records retained in the
  file (linker emission artifacts).
- -24 reserved vector points at the initfn, not a stub.
- Bundles the Motorola MC68343 FP firmware as hunk13 with its
  1981 copyright string — one of the earliest (WB1.0) builds.
