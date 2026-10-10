---
type: Function
title: XpksPackerInfo
description: Returns a pointer to the static XpkInfo descriptor block.
lvo: -30
timestamp: 2026-10-10T19:45:00Z
---

# Signature

```c
const struct XpkInfo *XpksPackerInfo(void);
```

# Semantics

`lea info(pc),a0; move.l a0,d0; rts` — returns the address of the
static `XpkInfo` descriptor stored inside the code hunk (.text+0x1ae in
the original). No parameters, no side effects.

The returned block describes the packer to xpkmaster.library: name
"NONE", long name "NoPacker", description "A dummy library that does
no compression", id `'NONE'`, flags 9 (`XPKIF_PK_CHUNK|XPKIF_UP_CHUNK`),
chunk limits 32K max / 20 min / 32K default, progress strings
"Writing"/"Reading"/"Wrote"/"Read", default mode 50, and a single
[XpkMode](../structures/XpkMode.md) descriptor "normal" rated
100/1/1918/2477. See [XpkInfo](../structures/XpkInfo.md).
