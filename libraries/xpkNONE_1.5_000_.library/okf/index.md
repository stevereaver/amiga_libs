---
type: Library
title: xpkNONE.library 1.5 (000)
description: >-
  XPK "store" sublibrary (dummy packer, no compression), 2013 Dirk
  Stoecker rebuild of xpkNONE. 644 bytes, single code hunk. AUTOINIT
  library with a word-offset function table (leading -1 marker) and a
  proper "$VER:" IdString.
tags: [xpk, sublibrary, packer, autoinit]
timestamp: 2026-10-10T09:20:00Z
---

# xpkNONE.library 1.5 (000) — Knowledge Bundle

`binary/xpkNONE_1.5(000).library` — sha256
`c1aedc8eee7a5fa478adfdaf8a6d3240931f35f9f88e2c55305521741951f92e`, 644
bytes, one code hunk (0x20c bytes, 17 RELOC32 entries). IdString:
`$VER: xpkNONE V1.5 (1 Oct 2013) by Dirk Stoecker\r\n`.

## Status

Fully reconstructed in C + skeleton asm. `source/` builds with
m68k-amigaos-gcc (two-pass link via `genfunctab.py` for the
word-offset function table) into a single-hunk `.library`. The header
region (entry stub, RomTag, name/id strings, InitTable dataSize,
InitStruct data) is byte-identical; function-table order/count, XpkInfo
and XpkMode contents match; code-hunk layout below the tables differs
(gcc codegen and object link order). All six sublibrary LVOs resolved
against `xpksub_lib.i` from the Aminet `xpk_Develop` archive.

## Contents

- [functions/](functions/index.md) — all 10 LVO entries (-6 .. -60)
- [structures/](structures/index.md) — XpkSubBase, XpkInfo/XpkMode, InitTable, hunk map
- [findings/](findings/index.md) — quirks and open questions
- [algorithms/](algorithms/index.md) — none (identity store)
- [log.md](log.md) — work journal

## Notes

- This is the 68000 build ("(000)") of Stoecker's 2013 re-release;
  sister builds `xpkNONE_1.2` and `xpkNONE_1.4` are also in the
  corpus.
- Unlike the 1.4 original, this build reads ExecBase from `4.W` and
  has no `xsb_SysBase` field (dataSize 0x26, not 0x2a).
