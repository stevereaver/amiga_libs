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
`1aff620aec8b2de4ed74d28da6c788d5aeffbdf42569de58b8bab6d8c57ccacf`,
md5 `63d5fd7d33d88c97157f13a5540b865b`, 740 bytes, one code hunk
(0x278 bytes, 14 RELOC32 entries stored **descending**). IdString:
`xpkRLEN 1.4 (1.12.2010)\r\n` — **no `$VER:` cookie**.

## Status

DONE — byte-identical + runtime-identical. `make` in `source/`
assembles the verbatim transcription `xpkRLEN_h0.s` (gas
`-m68000 -c`, link `-nostdlib -nostartfiles -Wl,-s`) and `fixup.py`
rewrites the RELOC32 tail to the original's descending order;
`cmp` + md5sum verify identity (md5
`63d5fd7d33d88c97157f13a5540b865b`). The earlier C model remains
buildable as `make cmodel` (NOT byte-identical). `work/oracle.py`
(machine68k) exercises init, all ten vectors, Pack/Unpack with live
param blocks, zero-length and error edges and deferred+real expunge;
orig-vs-rebuild logs are identical.

## Contents

- [functions/](functions/index.md) — all 10 LVO entries (-6 .. -60)
- [structures/](structures/index.md) — XpkSubBase, XpkInfo/XpkMode, InitTable, hunk map
- [algorithms/](algorithms/index.md) — the RLE codec
- [findings/](findings/index.md) — quirks and deviations
- [log.md](log.md) — work journal

## Notes

- The (000) V1.5 build `xpkRLEN_1.5_000_` in the corpus is a different
  encoder implementation — see its findings for the diff.
