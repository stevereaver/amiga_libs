---
type: Library
title: xpkRLEN.library 1.3 (01.04.1997)
description: >-
  XPK "Run Length" packer sublibrary - PackBits-style RLE codec.
  Rebuilt BYTE-IDENTICAL to the shipped binary (verbatim h0.s +
  fixup.py reloc rewrite); C model kept as reference.
timestamp: 2026-10-15T08:20:00Z
---

# xpkRLEN.library 1.3

XPK packer sublibrary (`RLEN` 4CC), six user vectors of the XpksSub
API.  This is the mid-generation build: AUTOINIT romtag, word-offset
function table, XpkInfo/XpkMode blocks embedded in the code hunk.

## Binary facts

- 1008 bytes; CODE hunk + small DATA hunk
- RomTag: AUTOINIT, v1 r3, NT_LIBRARY
- idstring `xpkRLEN 1.3 (01.04.1997)`
- XpkInfo: name "RLEN", longname "Run Length", desc "Fast and simple
  compression usable for simple data"

## Status

FULL - `source/` builds a byte-identical binary (verified by
fixup.py).  C model (`xpkRLEN.c`) mirrors the codec semantics.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
