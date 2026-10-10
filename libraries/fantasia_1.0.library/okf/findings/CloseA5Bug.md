---
type: Finding
title: LibClose reads flag through caller's a5
description: `btst #3,46(a5)` where a5 was never set — reads whatever the caller left there.
timestamp: 2026-10-10T18:00:00Z
---

# LibClose reads flag through caller's a5

LibClose never loads a5, yet tests `btst #3,46(a5)` for the
deferred-expunge flag.  The flag actually lives at base+0x2e and
should have been tested via a6 (as LibOpen does with `bclr #3,46
(a6)`).  Effect: after OpenCnt reaches 0, expunge only happens if
the caller's stale a5+0x2e has bit 3 set — essentially random.
OpenCnt is still decremented correctly.  Reproduced in C via a
register-pinned `__asm("a5")` alias.
