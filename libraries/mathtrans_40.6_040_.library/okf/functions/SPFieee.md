---
type: Function
title: SPFieee
description: IEEE-single to FFP converter, LVO -108.
---

# SPFieee — LVO -108

Shared helper AND public vector: converts the IEEE
single in d0 to FFP in d0 with range checking —
overflows return 0xFFFFFFFF with V set, tiny values
clamp to FFP 0.  Identical routine to the FPU sibling
build; used as the epilogue of every numerical
vector.
