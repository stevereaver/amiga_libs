---
type: Library
title: xpkFRLE.library 1.1 - "Fast Run Length Encoder"
description: >-
  XPK cache-optimized RLE chunk packer (FRLE 4CC).  Byte-identical
  rebuild via verbatim h0.s + fixup.py; C model in xpkFRLE.c.
timestamp: 2026-10-15T08:30:00Z
---

# xpkFRLE.library 1.1

XPK packer sublibrary ("Fast Run Length Encoder 1.0 / Cache-optimized
RLE").  AUTOINIT romtag, word-offset functab, embedded XpkInfo with
mode strings Packing/Unpacking/Packed/Unpacked.

## Status

FULL - `make` produces a BYTE-IDENTICAL binary (fixup.py verified).

## Contents

- [functions/](functions/index.md) - [structures/](structures/index.md)
- [findings/](findings/index.md) - [log.md](log.md)
