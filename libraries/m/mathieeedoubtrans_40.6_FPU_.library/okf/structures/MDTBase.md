---
type: Structure
title: MDTBase
description: 0x2c-byte library base.
---

# MDTBase — InitTable dataSize 0x2c

| off | contents |
|-----|----------|
| 0x00 | struct Library (34 B) |
| 0x22 | SysBase (a6 saved by LibInit) |
| 0x26 | seglist BPTR (a0 saved by LibInit) |
| 0x2a | private flag byte; bit3 = DELEXP |
| 0x2b | pad |

Same layout as the sibling mathieeedoubbas/mathieeesingtrans
40.6 builds -- the private DELEXP byte instead of lib_Flags
is a Martin Berndt framework signature.