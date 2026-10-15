---
type: Log
title: debox 1.7 work log
---

- Single CODE hunk; resident@+8 flags=0; functab@+0xfc
  (22 absolute vecs); initfn@+0x1e8 opens graphics v34 then
  MakeLibrary(dsize=0x6e)+AddLibrary.
- Verbatim transcription raw head through 0x158; byte-identical
  first pass; fixup splices 41-entry RELOC32 tail.
- Oracle: custom MakeLibrary trap; init/22 vectors/expunge
  identical (incl. a multi-MB INVALID read flood reproduced
  identically).
