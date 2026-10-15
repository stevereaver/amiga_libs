---
type: Library
title: nonvolatile.library 40.36 (WB3.1)
description: >-
  'nonvolatile 40.36 (14.9.93)' — OS 3.1 nonvolatile.library;
  single hunk with TWO RomTags (library + an AFTERDOS
  deinstall resident); word-offset functab, 11 vectors.
files:
  - source/nonvolatile_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# nonvolatile.library 40.36 (WB3.1)

Single 3472B CODE hunk, 16 RELOC32 entries.

- Resident@+4: fl=0x81 AUTOINIT v40, es->0xd60 (the second
  romtag), name->0x1b7 'nonvolatile.library', id->0x199
  'nonvolatile 40.36 (14.9.93)', init->InitTable@0x1e
- Second Resident@0xd60: fl=4 v0, name/id->0x196,
  init->0xd7a (post-dos cleanup routine calling
  exec CacheClearU + RemLibrary on self)
- InitTable@0x1e: dsz 0x9c, functab->0x2e, dtab=0,
  initfn->0x48
- functab@0x2e: word-offset format (ffff marker), 11 vectors
- deps: dos, utility, lowlevel, expansion libraries;
  'SYS:prefs/env-archive/sys/nv_location' default path
- init opens two libraries via exec -558 (OpenLibrary)

## Build

`nonvolatile_h0.s` verbatim .text; `fixup.py` splices the
16-entry RELOC32 tail.  Byte-identical (md5 0b468e86755a29f79479d33f046e535a).

## Runtime

`work/oracle.py`: init, all 11 vectors, open x2 (returns lib
base), close x2 (opencnt underflow), expunge.  Identical.
