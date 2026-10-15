---
type: Log
title: newfmt 4.2 work log
---

- 4-hunk layout decoded (InitTable hunk, aux CODE hunk,
  functab+strings hunk).
- Verbatim .text + merged .data; quickhelp-style resplit
  fixup; byte-identical first pass.
- Oracle needed set_invalid_func to bound the ~578.9M-access
  init sweep; identical original vs rebuild.
