---
type: Log
title: mathtrans 1.3 work log
---

- 17-hunk build; resident@h0+0; InitTable@h0+0x4c; functab
  h0+0x7a (18 entries, mixed h0/h1 targets).
- Inline-data density (jump tables + strings + firmware)
  makes mnemonic transcription impractical -> verbatim .byte
  streams per hunk, merged .text, resplit fixup.
- Byte-identical; oracle identical (init/18 vectors/expunge).
