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

## 2026-10-12

- Rewrote the reconstruction as verbatim assembly
  (`source/xpkNONE_v.s`), preserving gcc-canonicalisation traps as raw
  emits where needed; `fixup.py` rebuilds the original's scrambled
  28-entry RELOC32 tail (GNU ld emits ascending).
- `make` output is **byte-identical** to `binary/xpkNONE_1.4.library`
  (md5 `2e98fd5760fb158d697c3c183eb16827`).
- `work/oracle.py` (machine68k, adapted from xpkNONE_1.2): identical
  traces original vs rebuild — init (dead bsr-to-null path), open x2,
  reserved stubs, XpkInfo island fields, -36 -> -17
  (XPKERR_EXPANSION), CopyMem passthrough, deferred + real expunge
  (flag correctly set on the lib base, unlike 1.2's exec-base bug).
- Corrected an earlier theory: reloc entries at 0x1b6/0x1ba/0x1be are
  the XpkInfo name/packer/desc pointers — they do NOT land inside the
  idstring; no load-time string corruption exists.
