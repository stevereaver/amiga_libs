---
type: Function
title: XpksPackerInfo
description: Returns a pointer to the static XpkInfo descriptor block.
lvo: -30
timestamp: 2026-10-10T09:40:00Z
---

# Signature

```c
const struct XpkInfo *XpksPackerInfo(void);  /* -> d0 */
```

# Semantics

`lea info(pc),a0; move.l a0,d0; rts` — returns the `XpkInfo` block at
.text+0x21e. Name "RLEN", long name "Run Length", description "Fast
and simple compression usable for simple data", id `'RLEN'`, flags 9,
max chunk 0x7fffffff, min 0, default 0x4004, all four progress
messages NULL, default mode 50, one [XpkMode](../structures/XpkMode.md)
descriptor "normal" rated 100/1/140/1043 with ratio 45. See
[XpkInfo](../structures/XpkInfo.md).
