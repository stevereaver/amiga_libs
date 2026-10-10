---
type: Structure
title: XpkSubBase
description: 0x26-byte base.
---

# XpkSubBase — InitTable dataSize 0x26

| off | contents |
|-----|----------|
| 0x00 | struct Library (34 B) |
| 0x22 | seglist BPTR (written by LibInit) |

Minimal V1.1-style base; all descriptors are static data in
the code hunk.