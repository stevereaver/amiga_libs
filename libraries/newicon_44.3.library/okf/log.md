---
type: Log
title: newicon 44.3 work log
---

- 3-hunk build (CODE/DATA/BSS); DREL16 tails with bare-word
  terminators; resident@h1+0xa0; 13-vector functab@h1+0.
- Verbatim .text + .data(+12B BSS placeholder); fixup rewrites
  header/tags/tails; byte-identical.
- Oracle identical over init/13 vectors/expunge.
