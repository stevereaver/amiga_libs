---
type: Function
title: XpksPackerInfo
description: Returns a pointer to the static XpkInfo descriptor block.
lvo: -30
timestamp: 2026-10-10T09:20:00Z
---

# Signature

```c
const struct XpkInfo *XpksPackerInfo(void);  /* -> d0 */
```

# Semantics

`lea info(pc),a0; move.l a0,d0; rts` — returns the static `XpkInfo`
block at .text+0x13c in the original. No parameters, no side effects.

The block describes the packer to xpkmaster.library: `xi_XpkInfoVersion`
1, `xi_LibVersion` 1, `xi_MasterVersion` 2, `xi_ModesVersion` 0, both
name fields point at "NoPacker" (there is no separate short "NONE"
string in this build), description "A dummy library that does no
compression", id `'NONE'`, flags 9 (`XPKIF_PK_CHUNK|XPKIF_UP_CHUNK`),
chunk limits 32K max / 20 min / 32K default, progress strings
"Writing"/"Reading"/"Wrote"/"Read", default mode 100, and one
[XpkMode](../structures/XpkMode.md) descriptor "normal" rated
100/1/1450/1450. See [XpkInfo](../structures/XpkInfo.md).
