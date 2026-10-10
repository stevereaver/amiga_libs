---
type: Library
title: xpkNONE.library 1.4
description: >-
  XPK "store" sublibrary (dummy packer, no compression), 812 bytes,
  single code hunk. AUTOINIT library with a nonstandard table layout
  (function table before the RomTag) and no "$VER:" cookie in its
  IdString.
tags: [xpk, sublibrary, packer, autoinit]
timestamp: 2026-10-10T19:45:00Z
---

# xpkNONE.library 1.4 — Knowledge Bundle

`binary/xpkNONE_1.4.library` — sha256
`732b07e66d11cf507b4c5884ad93057fabdb936666117e69bb59233747ad1392`, 812
bytes, one code hunk (0x288 bytes, 23 RELOC32 entries). IdString:
`xpkNONE 1.4 (19.07.1998)\r\n` — **no `$VER:` cookie**.

## Status

Fully reconstructed in C. `source/` builds with m68k-amigaos-gcc into a
single-hunk `.library` whose entry opcode, function-table order/count,
padding, InitStruct bytes, InitTable, RomTag fields and name/id strings
are byte-identical to the original through the whole header region
(code-hunk offsets differ). All six sublibrary LVOs resolved against
the authoritative `xpksub_lib.i` from the Aminet `xpk_Develop`
archive.

## Contents

- [functions/](functions/index.md) — all 10 LVO entries (-6 .. -60)
- [structures/](structures/index.md) — XpkSubBase, XpkInfo/XpkMode, InitTable, hunk map
- [findings/](findings/index.md) — quirks and open questions
- [log.md](log.md) — work journal

## Notes

- External reference material used: `xpk_Develop.lha` from Aminet
  (sublib LVO names, `struct XpkInfo`/`XpkMode`/`XpkSubParams` ABI,
  `XPKERR_*` codes, `XPKIF_*` flags).
- Sister builds `xpkNONE_1.2` and `xpkNONE_1.5(000)` are in the corpus;
  1.5 is a 2013 Dirk Stöcker rebuild with a proper `$VER:` string.
