---
type: Structure
title: XpkSubBase
description: 0xfc-byte base with embedded descriptors.
---

# XpkSubBase — InitTable dataSize 0xfc

| off | contents |
|-----|----------|
| 0x00 | struct Library (34 B) |
| 0x22 | seglist BPTR (LibInit) |
| 0x26 | XpkInfo, 88 B (InitStruct-filled) |
| 0x7e | XpkMode, 42 B (InitStruct-filled) |
| 0xa8..0xfb | unused (84 B — probably reserved for state) |

The descriptors are data-table initialised, not code:
the only field LibInit writes is xi_ModeDesc (base+0x62)
because the InitStruct stream cannot express
base-relative pointers.
