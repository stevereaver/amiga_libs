---
type: Library
title: wbstart.library 45.1 (16.12.00)
description: >-
  Wraps workbench.library OpenWorkbenchObjectA(): takes a tag list
  (name, optional dir lock, optional {lock,name} arg pairs), changes
  directory, opens the object, restores state.
timestamp: 2026-10-10T20:00:00Z
---

# wbstart.library 45.1 (16.12.00)

Two-hunk library that packages Workbench object launching: its
single real vector `WBStart(tagList)` turns tags into an
`OpenWorkbenchObjectA(name, WBOPENA_ArgLock/ArgName pairs)` call,
optionally after `CurrentDir()` to a supplied lock or to the
directory part of the object name.

## Binary facts

- sha256 `2f627e3c293159a651d12068ee384e7879e928d48902edad5dd8950c21646460`, 1008 bytes
- hunks: CODE 0x318 bytes (+pad), DATA 0x78 bytes
- RomTag in the DATA hunk: RTF_AUTOINIT, RT_VERSION **2** (!),
  NT_LIBRARY, pri 0; EndSkip covers the data hunk
- idstring: `wbstart.library 45.1 (16.12.00)`
- InitTable dataSize 0x38, absolute-longword functab, no
  InitStruct data (exec fills name/id/version from the RomTag;
  init writes lib_Revision = 2)
- 6 vectors + -1L terminator: Open, Close, Expunge, reserved(-24),
  reserved(-30, same stub), WBStart(-36)
- module entry returns -1 (not executable); reserved stub returns 0
- init opens workbench.library v45, dos.library v40,
  utility.library v40; any failure aborts init

## Status

**Byte-identical.**  `source/wbstart_h0.s` is a verbatim gas
reconstruction of both hunks; `source/fixup.py` rewrites GNU
ld's HUNK_RELOC32 tail into the shipped HUNK_DREL32 (0x3f7,
word offsets) tail — md5 `ab05a79789225bdf074a6f808ed4ca57`,
1008 bytes.  `work/oracle.py` (machine68k) runs both binaries
through init/open/close/expunge, both reserved stubs and 11
WBStart scenarios (all tag handlers, PathPart truncation,
wbtags build, AllocVec/OWO failure): logs are identical.
The earlier C model is kept under `make cmodel`.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
