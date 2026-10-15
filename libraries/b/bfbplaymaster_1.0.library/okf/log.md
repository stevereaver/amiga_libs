---
type: Log
title: bfbplaymaster 1.0 work log
---

- Single CODE hunk; resident@+4 v1; InitTable@+0x474; 19-entry
  absolute functab@+0x484; datatab@+0x4d4; initfn@+0x4f4 opens
  dos.library.
- Verbatim transcription with raw head through 0x4f4;
  byte-identical first pass; fixup splices the 29-entry tail.
- Oracle identical: init/19 vectors/deferred+real expunge.
