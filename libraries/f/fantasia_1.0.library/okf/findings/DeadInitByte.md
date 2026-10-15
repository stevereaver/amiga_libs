---
type: Finding
title: InitStruct `a0 0c 09` dead store — ln_Type never set
description: >-
  The InitStruct datatab writes byte 9 at lib+0x0c (inside the
  ln_Name long) immediately before the long write at +0x0a
  overwrites it; ln_Type (+0x08) is never written and stays 0.
timestamp: 2026-10-15T00:00:00Z
---

# Dead InitByte command

The datatab opens with `a0 0c 09` — InitStruct BYTE write of 9 at
offset +0x0c, i.e. the middle of the `ln_Name` field (+0x0a..+0x0d).
Two commands later `80 0a <name>` writes the whole name pointer
long at +0x0a, clobbering the byte.

Net effect: `ln_Type` (+0x08) is never initialized — the library
node reports `ln_Type = 0`, not `NT_LIBRARY(9)`.  The 6-byte
`bne.l +4` after `OpenLibrary(dos)` is likewise degenerate: branch
target == fall-through address, so a failed DOS open is silently
accepted (and a NULL dosbase is later CloseLibrary'd in Expunge).

Same codegen family as `version_1.1` / `_asl._40.6` — verified by
oracle (`type=0` after init).
