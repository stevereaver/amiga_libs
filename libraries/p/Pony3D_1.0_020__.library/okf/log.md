---
type: Log
title: Pony3D 1.0 work log
---

- 3-hunk build; resident mid-hunk0@+0xca; InitTable@+0x172 with
  cross-hunk functab (4 entries ->h1).
- Verbatim transcription merged h0+h1 code + h2 data;
  byte-identical first pass; fixup resplits + splices tails.
- Oracle identical: init/8 vectors/deferred+real expunge.
