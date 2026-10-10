---
type: Function
title: LibOpen
description: LVO -6 -- open the library.
---

# LibOpen — LVO -6

Increments `lib_OpenCnt` (+0x20), clears the private DELEXP
bit (bit3 of base+0x2a), returns the base in d0.
