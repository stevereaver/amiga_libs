---
type: Findings
title: newicon 44.3 quirks
---

# Findings / quirks

- DREL16 sections terminate with a bare zero WORD and pad to
  long-align the following END — an underdocumented hunk
  detail.
- initfn frees a private 0xa2-byte scratch block.
- -24 reserved vector points at the h0+6 stub.
