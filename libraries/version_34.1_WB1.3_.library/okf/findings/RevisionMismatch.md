---
type: Finding
title: lib_Revision anomaly
description: lib_Revision=28 does not match the 34.1 id string.
timestamp: 2026-10-10T19:00:00Z
---

# lib_Revision anomaly

The InitStruct data sets `lib_Version`=34 but
`lib_Revision`=28, while the id string says "versionlib 34.1 (06 JUL 1988)".
Identical to version_34.1.library in every byte except this word (28 vs 32).  The fields are reproduced verbatim.
