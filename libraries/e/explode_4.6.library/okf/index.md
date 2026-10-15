---
type: Library
title: explode.library 4.6 - "Executable exploder" (1 Feb 1990)
description: >-
  Combined decruncher and relocating loader for "exploded"
  executables. Hooks DOS LoadSeg at init so packed programs
  auto-decompress when loaded; the single public vector is a
  decrunch-and-run entry called with inline packed data.
---

# explode.library 4.6

Runtime decruncher for the "Explode" executable packer (successor to
the 4.3 "Executable file exploder", DSI copyright notice dropped).
At init it opens `dos.library` and `SetFunction`-patches the DOS
`LoadSeg` vector (-0x96).  The hook inspects every loaded program:
if the first hunk carries the explode signature (`48e7ffff` MOVEM
prologue, the four `expl`/`ode.`/`libr`/`ary\0` longword marks) it
runs the decoder in place, then returns the decompressed seglist.

## Binary facts

- 1504 bytes, single CODE hunk 0x564
- RomTag: RTF_AUTOINIT, version 4, NT_LIBRARY, pri 0
- idstring: `Executable exploder V4.6 (1 Feb 1990)\r\n`
- InitTable dataSize 0x36, extended c/d/e InitStruct encoding
- Absolute-longword function table: Open, Close, Expunge, Reserved
  (all three = null stub), one user vector `-30`
- No `$VER:` cookie; module entry returns -1

## Public API

| LVO  | Name      | Notes |
|------|-----------|-------|
| -30  | Explode   | decrunch+relocate+run; inline packed data after the JSR |

No official FD/header known; the name `Explode` is descriptive.

## 4.3 -> 4.6 deltas

- idstring/date/revision change (rev 6); DSI copyright dropped.
- OpenLibrary failure now `jmp`s into `Alert` with the DEADEND
  flag set (`0x80038007`) - 4.3 used a recoverable `jsr` and
  continued with a NULL dosbase.
- stub-counter patching moved ahead of the vector inspection.
- vector-walk failure now Alerts `0x00028007` and RETURNS WITHOUT
  patching - 4.3 branched back and re-inspected forever (hang).
- LoadSeg hook NULL-checks the returned seglist and verifies all
  four signature longs (`ode.` + `libr` added; 4.3 checked only
  `expl` + `ary\0`).
- decoder frame shrank 0x44 -> 0x3e: saved task/oldpri moved out
  of the frame onto the stack; xf_outcount now at +58.
- decoder core (bit reader, token tree, ring copy-out, reloc
  driver, hunk teardown) is byte-identical with 4.3.

## Status

FULL - reconstructed (`source/`), builds with m68k-amigaos-gcc
-m68000 to a valid hunk library.  Decoder algorithm ported to C
(`explode.c`); ABI-critical glue (hook stubs, frame layout,
tail-jump entry) in `explode_lib.s`.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [algorithms/](algorithms/index.md)
- [findings/](findings/defects.md)
- [log.md](log.md)
