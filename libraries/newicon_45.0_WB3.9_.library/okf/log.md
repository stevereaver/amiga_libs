---
type: Log
title: newicon 45.0 work log
---

- 2-hunk build, DREL16 tails; resident@h1+0xa0,
  InitTable@h1+0x90, 13-entry functab@h1+0 -> h0.
- Verbatim .text + raw .data; fixup extended with a
  word-group DREL16 walker; byte-identical.
- Oracle identical: init/13 vectors/deferred+real expunge.
