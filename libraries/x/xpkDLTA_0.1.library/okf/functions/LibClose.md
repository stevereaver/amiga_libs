---
type: Function
title: LibClose
description: Library close vector.
---

# LibClose — LVO -12

Decrements OpenCnt; on zero with DELEXP set, `bsr`s to
the expunge body.  Returns seglist BPTR on expunge,
else 0.
