---
type: Library
title: wbstart.library 45.2 (16.07.01) "Emulation by Stephan Rupprecht"
description: >-
  Third-party clean-room emulation of Commodore's wbstart 45.1:
  same base layout and tag API, but the object start resolves
  "VOL:", "dev:dir/file" and bare names differently and walks the
  Workbench search path via WorkbenchControlA.
timestamp: 2026-10-15T03:51:25Z
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

**Byte-identical.**  `source/wbstart_h0.s` is a verbatim gas
reconstruction of both hunks; `source/fixup.py` rewrites the
CODE-hunk RELOC32 group's offset order into the shipped
non-sorted `{1dc, 1cc}` form — md5 `45964497863bb8fbb534faed27da44fa`,
1760 bytes.  `work/oracle.py` (machine68k) runs both binaries
through init/open/close/expunge, both reserved stubs and 14
WBStart scenarios (all tag handlers, `.info` retry, `dev:`/
`dev:dir/file` resolution, search-path walk hit and miss,
PrintFault, AllocVec/OWO failure): logs are identical.
The earlier C model is kept under `make cmodel`.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
