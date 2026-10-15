---
type: Log
title: sz_aio_ahi 0.2 work log
---

- Single CODE hunk, resident@+4 (v0), InitTable@+0x1e,
  functab@+0xb3e (7 absolute vecs), datatab@+0x2e,
  initfn@+0x4e.
- Verbatim transcription, raw head through 0x60; byte-identical
  first pass; fixup splices 54-entry RELOC32 tail.
- Oracle: init, 7 vectors, deferred+real expunge — identical
  original vs rebuild (short trace + INVALID walks).
