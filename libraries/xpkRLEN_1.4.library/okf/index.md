---
type: Library
title: xpkRLEN.library 1.4
description: >-
  XPK run-length (PackBits-style) chunk packer, 740 bytes, single code
  hunk. AUTOINIT library with a word-offset function table, no "$VER:"
  cookie, and RT_ENDSKIP at module end.
tags: [xpk, sublibrary, packer, rle, autoinit]
timestamp: 2026-10-10T09:40:00Z
---

# xpkRLEN.library 1.4 — Knowledge Bundle

`binary/xpkRLEN_1.4.library` — sha256
`1aff620aec8b2de4ed74d28da6c788d5aeffbdf42569de58b8bab6d8c57ccacf`, 740
bytes, one code hunk (0x278 bytes, 14 RELOC32 entries). IdString:
`xpkRLEN 1.4 (1.12.2010)\r\n` — **no `$VER:` cookie**.

## Status

Fully reconstructed in C + skeleton asm. `source/` builds with
m68k-amigaos-gcc (two-pass link via `genfunctab.py`) into a
single-hunk `.library`. Entry stub, RomTag fields and
InitStruct/InitTable contents match; the RLEN encoder and decoder are
instruction-faithful to the original; code-hunk layout and offsets
differ (gcc codegen). All six sublibrary LVOs resolved against
`xpksub_lib.i`.

## Contents

- [functions/](functions/index.md) — all 10 LVO entries (-6 .. -60)
- [structures/](structures/index.md) — XpkSubBase, XpkInfo/XpkMode, InitTable, hunk map
- [algorithms/](algorithms/index.md) — the RLE codec
- [findings/](findings/index.md) — quirks and deviations
- [log.md](log.md) — work journal

## Notes

- The (000) V1.5 build `xpkRLEN_1.5_000_` in the corpus is a different
  encoder implementation — see its findings for the diff.
