---
type: Finding
title: 45.2 vs. the 45.1 original
description: How this third-party emulation differs from Commodore's wbstart 45.1.
timestamp: 2026-10-10T21:10:00Z
---

# 45.2 vs. 45.1

The idstring identifies this build as "Emulation by Stephan
Rupprecht" — a clean-room reimplementation of the Commodore
wbstart.library 45.1 (16.12.00) interface, carrying a higher
advertised version.  Same public contract, different internals:

| aspect | 45.1 (CBM) | 45.2 (emulation) |
|---|---|---|
| size / hunks | 1008 B; CODE 0x318, DATA 0x78 | 1760 B; CODE 0x5a4, DATA 0x98 |
| base layout | 0x38 | 0x38 (identical) |
| name resolution | `PathPart` + `Lock` on dir part | own `Lock(name)`/`Lock(".info")` probe, `ParentDir`+`FilePart` |
| bare-name fallback | none beyond the lock | walks **Workbench search path** via `WorkbenchControlA` |
| failure reporting | silent | `PrintFault(IoErr(), name)` |
| `"VOL:"` handling | via PathPart/lock path | opens the volume root directly |
| reserved stub | `moveq #0,d0` | `clr.l d0` |
| icon-only tools | no | `Lock("<name>.info")` fallback |
| tag API | TAG_USER+1..7 | identical |

The API is otherwise a drop-in replacement: same LVO layout,
same tag semantics, same 0/20 return convention, same RomTag
version-2 quirk (the emulation even reproduces the RT_VERSION
patch that the original effectively performed by writing
lib_Revision).
