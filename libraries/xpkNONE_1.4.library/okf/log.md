---
type: Log
title: Work journal
---

# Log

## 2026-10-10

- Disassembled binary (ira → work/xpkNONE_1.4.asm); decoded the
  nonstandard layout: function table at +0x04, InitStruct data +0x54,
  InitTable +0x74 (dataSize 0x2a), RomTag +0x84, strings +0x9e/+0xae.
- Pulled `xpk_Develop.lha` from Aminet for authoritative names:
  sublib LVOs per `xpksub_lib.i` (-30 XpksPackerInfo, -36 XpksPackChunk,
  -54 XpksUnpackChunk; -42/-48/-60 share the null stub), plus the
  `XpkInfo`/`XpkMode`/`XpkSubParams` ABI and `XPKERR_*` codes.
- Decoded embedded descriptors: XpkMode "normal" @+0x184, XpkInfo
  @+0x1ae (flags 9, 'NONE' id, 32K chunks, mode 50).
- Reconstructed C source (xpknone_lib.s + xpknone.c + xpkbase.h);
  `make` produces a single-hunk .library byte-identical through the
  header region.
- Documented findings: missing $VER cookie, functab-before-romtag
  layout, unconditional DELEXP, dead init hook, XpkInfoVersion=0,
  -1 entry stub.
