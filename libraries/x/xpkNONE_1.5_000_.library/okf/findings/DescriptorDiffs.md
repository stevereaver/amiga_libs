---
type: Finding
title: Descriptor differences vs. 1.4
description: XpkInfo/XpkMode values that changed between the 1998 and 2013 builds.
timestamp: 2026-10-10T09:20:00Z
---

# Descriptor differences vs. 1.4

Same packer, but the embedded descriptors were touched up in the 2013
rebuild:

| field | 1.4 (1998) | 1.5 (2013) |
|-------|-----------:|-----------:|
| xi_XpkInfoVersion | 0 | 1 |
| xi_LibVersion | 1 | 1 |
| xi_MasterVersion | 1 | 2 |
| xi_ModesVersion | 0 | 0 |
| xi_Name | "NONE" | "NoPacker" |
| xi_LongName | "NoPacker" | "NoPacker" (same ptr) |
| xi_DefMode | 50 | 100 |
| xm_PackSpeed | 1918 | 1450 |
| xm_UnpackSpeed | 2477 | 1450 |

`xi_MasterVersion` 2 reflects the newer xpkmaster the sublib was built
against; `xi_DefMode` 100 still lands inside the single mode's 0..100
range. The speed ratings were halved/equalised — presumably
re-measured on different reference hardware or simply normalised.
