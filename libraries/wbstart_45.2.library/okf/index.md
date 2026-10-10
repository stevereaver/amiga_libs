---
type: Library
title: wbstart.library 45.2 (16.07.01) "Emulation by Stephan Rupprecht"
description: >-
  Third-party clean-room emulation of Commodore's wbstart 45.1:
  same base layout and tag API, but the object start resolves
  "VOL:", "dev:dir/file" and bare names differently and walks the
  Workbench search path via WorkbenchControlA.
timestamp: 2026-10-10T21:10:00Z
---

# wbstart.library 45.2 (16.07.01) Emulation by Stephan Rupprecht

Two-hunk library that emulates the original wbstart.library
API: `WBStart(tagList)` turns tags into an
`OpenWorkbenchObjectA(name, WBOPENA_ArgLock/ArgName pairs)` call,
optionally after `CurrentDir()` to a supplied lock.  Unlike the
45.1 original, the object-name resolution is reimplemented: it
probes `Lock(name)`/`Lock("name.info")` itself, splits explicit
`dev:dir/file` paths via `ParentDir`+`FilePart`, and for bare
names falls back to walking the Workbench search path obtained
with `WorkbenchControlA(WBCTRLA_DuplicateSearchPath)`, printing a
dos fault with `PrintFault()` when nothing matches.

## Binary facts

- sha256 `c0b12320ccbce1727d196ba31f35f26fede2aa0a71987f4a878696b50b01adc9`, 1760 bytes
- hunks: CODE 0x5a4 bytes, DATA 0x98 bytes
- RomTag in the DATA hunk: RTF_AUTOINIT, RT_VERSION **2**,
  NT_LIBRARY, pri 0; EndSkip covers the data hunk
- idstring: `wbstart.library 45.2 (16.07.01) Emulation by Stephan Rupprecht`
- InitTable dataSize 0x38, absolute-longword functab, no
  InitStruct data (exec fills name/id/version from the RomTag;
  init writes lib_Revision = 2 AND patches the RomTag RT_VERSION
  byte at runtime — self-modifying write into the data hunk)
- 6 vectors + -1L terminator: Open, Close, Expunge, reserved(-24),
  reserved(-30, same stub), WBStart(-36)
- module entry returns -1 (not executable); reserved stub returns
  0 via `clr.l d0` (45.1 used `moveq #0,d0`)
- init opens workbench.library v45, dos.library v40,
  utility.library v40; any failure aborts init
- code hunk ends with two dead libc-style string routines
  (strcat/strcpy shapes) that are never called

## Status

FULL — reconstructed in C + asm header (`source/wbstart.c`,
`wbstart_lib.s`, `endmodule.s`; m68k-amigaos-gcc -m68000, single
pass, absolute vectors).  `make` builds a valid
`wbstart.library`.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
