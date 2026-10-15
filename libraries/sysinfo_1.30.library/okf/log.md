---
type: Log
title: sysinfo 1.30 work log
---

- 3-hunk build: CODE 3148B + DATA 28B + CODE 96B; resident@h0+4,
  all three rt pointers relocated cross-hunk.
- Verbatim .s with h1+h2 merged .data; fixup re-splits into the
  original header and splices 3 reloc tails; byte-identical.
- Oracle identical: init/16 vectors/deferred+real expunge.
