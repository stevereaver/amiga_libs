---
type: Log
title: fwpenpal 3.0 work log
---

- DATA/CODE swapped-tag layout decoded: resident@h0+0xc60,
  InitTable@h0+0xc50, 5-vector functab@h0+0xc38,
  `jmp h1+0` trampoline@h0+0xc30.
- Verbatim .text (orig DATA) + raw .data (orig CODE); fixup
  re-tags; byte-identical first pass.
- Oracle identical: init/5 vectors/open-close/expunge
  (opencnt underflow reproduced).
