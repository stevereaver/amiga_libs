---
type: Finding
title: xi_XpkInfoVersion = 0
timestamp: 2026-10-10T19:45:00Z
---

# XpkInfo version field is 0

The `xi_XpkInfoVersion` field in the embedded
[XpkInfo](../structures/XpkInfo.md) block is 0 (`xi_LibVersion` = 1,
`xi_MasterVersion` = 1, `xi_ModesVersion` = 0). Later XPK headers
describe the structure as "version 1 of XpkInfo"; this 1998 build
predates (or ignores) the versioning field and reports 0. The rest
of the layout matches the 4.x `struct XpkInfo` exactly — all pointer
fields, strings, flags and the XpkMode chain land correctly.
