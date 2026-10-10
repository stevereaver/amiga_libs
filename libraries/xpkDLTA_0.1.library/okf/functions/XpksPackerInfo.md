---
type: Function
title: XpksPackerInfo
description: Returns the XpkInfo descriptor.
---

# XpksPackerInfo — LVO -30

`lea a6@(0x26),a0` — returns the XpkInfo descriptor at
base+0x26 (InitStruct-filled; xi_ModeDesc patched by
LibInit to base+0x7e).
