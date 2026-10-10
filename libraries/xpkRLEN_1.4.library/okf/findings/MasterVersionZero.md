---
type: Finding
title: xi_MasterVersion = 0
description: The descriptor claims it needs xpkmaster version 0.
timestamp: 2026-10-10T09:40:00Z
---

# xi_MasterVersion = 0

`xi_MasterVersion` at XpkInfo+0x04 is 0 as shipped. Every other
sublib in the corpus carries 1 or 2 there. A zero simply means "any
xpkmaster works" — harmless, but it looks like an unfinished
boilerplate field (this packer really only uses the v1 chunk ABI
anyway, so 0 is accidentally accurate).
