---
type: Library
title: explode.library 4.3 - "Executable file exploder" (29 May 1989, DSI)
description: >-
  Combined decruncher and relocating loader for DSI "exploded"
  executables. Hooks DOS LoadSeg at init so packed programs
  auto-decompress when loaded; the single public vector is a
  decrunch-and-run entry called with inline packed data.
timestamp: 2026-10-10T21:30:00Z
---

# explode.library 4.3

Runtime decruncher for the DSI "Explode" executable packer.  At init
it opens `dos.library` and `SetFunction`-patches the DOS `LoadSeg`
vector (-0x96).  The hook inspects every loaded program: if the first
hunk carries the explode signature (`48e7ffff` MOVEM prologue,
`expl`/`ary\0` marks) it runs the decoder in place, then returns the
decompressed seglist.

## Binary facts

- sha256 `eb5f60572c03a075d3f9047e82a0d31c7ec1e0eca9b41eb9713036ef635fd9c3` (see log), 1488 bytes, single CODE hunk 0x55c
- RomTag: RTF_AUTOINIT, version 4, NT_LIBRARY, pri 0
- idstring: `Executable file exploder V4.3 (29 May 1989) \xa9 DSI\r\n`
- InitTable dataSize 0x36, extended c/d/e InitStruct encoding
- Absolute-longword function table: Open, Close, Expunge, Reserved
  (all three = null stub), one user vector `-30`
- No `$VER:` cookie; module entry returns -1

## Public API

| LVO  | Name      | Notes |
|------|-----------|-------|
| -30  | Explode   | decrunch+relocate+run; inline packed data after the JSR |

No official FD/header known; the name `Explode` is descriptive.

## Status

BYTE-IDENTICAL - verbatim asm reconstruction (`source/explode_h0.s`)
+ `source/fixup.py` (16-entry RELOC32 splice): `cmp`-equal to the
shipped binary (md5 `7a9731be26727440731cc77ed97eed47`).
machine68k oracle (`work/oracle.py`) identical over entry, init
(OpenLibrary dos + SetFunction dos@-0x96 -> in-hunk hook), all 5
vectors, and two calls through the installed hook (LoadSeg
passthrough + Supervisor-walked seglist check).  The earlier
semantic C model is preserved as the `cmodel` make target.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [algorithms/](algorithms/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
