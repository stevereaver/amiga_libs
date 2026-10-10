---
type: Log
title: Work journal
---

# Log

## 2026-10-10

- Disassembled binary (ira -M68000 → work/fwfiltertype_3.0.asm); decoded
  RomTag, InitTable (dataSize 0x28, absolute-long functab) and compact
  InitStruct stream.
- Resolved all 6 LVO slots: standard skeleton (Open/Close/Expunge/Null)
  + FwFilterType at -30 + second reserved null at -36.
- Reconstructed C source (fwfiltertype_lib.s + fwfiltertype.c +
  fwbase.h); `make` builds a single-hunk .library with identical header
  layout and InitStruct bytes.
- Documented findings: dead cmpi, idstring-inside-$VER trick, unused
  third arg, unknown caller contract.
