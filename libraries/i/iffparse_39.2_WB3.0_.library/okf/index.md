---
type: Library
title: iffparse.library 39.2 (28.8.92) - WB3.0
description: >-
  IFF file parser - Workbench 3.0 build.  Sibling of the
  reconstructed iffparse_40.1; shares the C model.
timestamp: 2026-10-15T11:00:00Z
---

# iffparse.library 39.2 (WB3.0)

IFF parse library, WB3.0 build.  Same codebase as the completed
iffparse_40.1 reconstruction - the C model is shared.

## Delta vs 40.1

- version 39/2, idstring `iffparse 39.2 (28.8.92)`
- dataSize 0x4c (vs 0x48 in 40.1), minor code-hunk drift
- otherwise identical API / functab layout

## Status

FULL - builds via cloned 40.1 source with version edits.

## Contents

- see ../iffparse_40.1_WB3.1_.library/okf/ for the full decode;
  this bundle documents the sibling delta.
