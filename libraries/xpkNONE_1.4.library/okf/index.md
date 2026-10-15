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
bytes, one code hunk (0x288 bytes, 28 RELOC32 entries). IdString:
`xpkNONE 1.4 (19.07.1998)\r\n` — **no `$VER:` cookie**.

## Status

**Byte-identical and runtime-identical.** `source/xpkNONE_v.s` is a
verbatim 68k assembly reconstruction; `make` (m68k-amigaos-gcc +
`fixup.py`, which rewrites the scrambled 28-entry RELOC32 tail in the
original's descending order) produces a `cmp`-clean copy of the shipped
binary (md5 `2e98fd5760fb158d697c3c183eb16827`). `work/oracle.py`
(machine68k) gives identical traces for init/open/close, all stub
vectors, XpksPackerInfo layout, -36 -> -17, the CopyMem passthrough,
and deferred + real expunge. The earlier C reconstruction is retained
and still builds via `make cmodel`. All six sublibrary LVOs resolved
against `xpksub_lib.i` from the Aminet `xpk_Develop` archive.

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
