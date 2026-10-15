---
type: Library
title: lsdetect.library 1.0 "LightShock EnvDetector V1.0"
description: >-
  Environment detector for the LightShock game engine: language
  detection (lowlevel / locale / RAW: console prompt) and a
  borrow/restore pair around Intuition's ActiView.
timestamp: 2026-10-10T20:40:00Z
---

# lsdetect.library 1.0 — "LightShock EnvDetector V1.0"

Three user vectors: `LSDetectLanguage` (cached Italian/English/
German detection with three fallbacks) and `LSBorrowScreen` /
`LSReleaseScreen` which stash and restore `GfxBase->ActiView`
plus colour 0 while the game owns the display.

## Binary facts

- sha256 `a10b42269e2c80dc830d84bc4649d0adf3645ff702fc9bfacd55bc09f992ddf9`, 1160 bytes
- hunks: single CODE hunk 0x410 bytes
- RomTag: RTF_AUTOINIT, version 1, NT_LIBRARY, pri 0
- idstring: `LightShock EnvDetector V1.0` (stored with a leading
  NUL byte; RomTag/InitStruct reference IDSTRING+1)
- InitTable dataSize 0x44, InitStruct data, absolute-longword
  functable, 7 vectors + -1L
- init opens graphics, lowlevel, dos, locale (v0, unchecked);
  sets language byte to -1
- embedded prompt: `\n Please select your preferred language:\n\n
  F1 - Italiano\n\n   F2 - English\n\n   F3 - Deutsch\n` (94 bytes)
- window spec: `RAW:0/0/600/120/Language Selection`

## Status

BYTE-IDENTICAL - verbatim asm `source/lsdetect_h0.s` + `fixup.py`
(17-entry RELOC32 splice): `cmp`-equal to the shipped binary (md5
`84bba53e40d3b7dce80ca5772cab3aa3`).  Semantic
C model kept as `cmodel` target.  machine68k oracle identical over
entry/init (4 support libraries opened)/all 7 vectors/expunge.
`make` produces `lsdetect.library`.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
