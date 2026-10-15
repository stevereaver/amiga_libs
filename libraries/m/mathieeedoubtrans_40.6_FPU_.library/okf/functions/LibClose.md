---
type: Function
title: LibClose
description: Library close vector.
---

# LibClose — LVO -12

Pre-zeroes d0, decrements OpenCnt; on zero with private
DELEXP (base+0x2a bit3) set, falls into the expunge body.
Returns seglist on expunge else 0.