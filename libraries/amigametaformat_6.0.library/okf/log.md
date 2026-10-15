---
type: Log
title: amigametaformat 6.0 work log
---

- Single CODE hunk, resident@+4 (v6), InitTable@+0x1e,
  functab@+0xc2e (7 absolute vecs), datatab@+0x2e,
  initfn@+0x44e.
- Verbatim transcription, raw head through 0x60; byte-identical
  first pass; fixup splices 19-entry RELOC32 tail.
- Oracle: init, 7 vectors, deferred+real expunge — identical
  original vs rebuild (443-line trace incl. INVALID walks).
