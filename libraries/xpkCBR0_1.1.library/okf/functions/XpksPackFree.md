---
type: Function
title: XpksPackFree
description: Unused sublib slot.
---

# XpksPackFree — LVO -42

Points at the bare `rts` — returns whatever d0 held
(the original shares one rts word for all three unused
slots).  No state to free; the packer is stateless.
