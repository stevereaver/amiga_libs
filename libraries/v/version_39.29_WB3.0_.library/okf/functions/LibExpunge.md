---
type: Function
title: LibExpunge
description: Expunge vector -- a shared moveq #0,d0/rts stub that never expunges.
lvo: -18
registers: -
---

# `LONG LibExpunge(void)` — stub

**LVO -18** — the function-table entry for Expunge is the word
offset 0x62, i.e. text+0xba, the *same* `moveq #0,d0 / rts` used
by ExtFunc.  Calling Expunge() therefore does nothing and returns
NULL: the real removal happens in [LibClose](LibClose.md) when the
open count reaches zero.  See
[CloseSemantics](../findings/CloseSemantics.md).
