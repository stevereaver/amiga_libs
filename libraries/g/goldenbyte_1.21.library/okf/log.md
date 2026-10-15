---
type: Log
title: goldenbyte 1.21 work log
---

- Single CODE hunk, resident@+4, InitTable@+0x50, 25-entry
  absolute functab@+0x60, initfn@+0xc8.
- Verbatim transcription with raw head through 0xc0;
  byte-identical first pass; fixup splices the RELOC32 tail.
- Oracle: init opens 10 libs, all 25 vectors, deferred+real
  expunge — identical original vs rebuild.
