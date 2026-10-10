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

Reconstructed (`source/`, m68k-amigaos-gcc -m68000, single pass,
absolute vectors).  The rebuilt `.data` hunk is byte-layout
identical (functab@0x00, name@0x1c, id@0x2c, init@0x4c,
romtag@0x5c, endskip@0x76).

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
