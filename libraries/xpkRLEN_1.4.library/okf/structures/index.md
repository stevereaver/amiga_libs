---
type: Index
title: Structures
description: Library base, XPK descriptors, table layout.
---

# Structures

- [XpkSubBase](XpkSubBase.md) — private library base (dataSize 0x2a, field unused)
- [XpkInfo](XpkInfo.md) — packer descriptor at .text+0x21e
- [XpkMode](XpkMode.md) — mode descriptor at .text+0x1f4 ("normal")
- [XpkSubParams](XpkSubParams.md) — chunk I/O parameters (ABI)
- [InitTable](InitTable.md) — AUTOINIT table, word-offset functab
- [HunkMap](HunkMap.md) — single code hunk layout
