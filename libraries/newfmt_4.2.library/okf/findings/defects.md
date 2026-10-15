---
type: Findings
title: newfmt 4.2 quirks
---

# Findings / quirks

- Initfn performs a ~578.9M-access sweep across unmapped
  memory (reads at descending 0xfffffxxx addresses) under the
  minimal oracle — reproduced identically on the rebuild.
- -24 reserved vector points at the initfn (0x20) rather than
  a stub.
- Close frees the private area but leaves opencnt underflowed
  on double-close.
