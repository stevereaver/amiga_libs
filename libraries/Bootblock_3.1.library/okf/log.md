---
type: Log
title: Bootblock 3.1 work log
---

- Parsed 4 hunks: CODE 0x1dc (resident+initfn), CODE 0x70
  (strings + 12-entry functab), DATA 0x60 zeros, CODE 0x8c0
  (implementation, dos/expansion/trackdisk).
- Verbatim transcription merged h0+h3 into .text and h1+h2 into
  .data; fixup.py re-splits and splices all reloc groups.
  Byte-identical first pass.
- Oracle: 4-hunk load, cross-hunk relocs, init, all 12 vectors,
  deferred+real expunge — identical original vs rebuild.
