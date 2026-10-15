---
type: Library
title: mhimaspro_1.5 (26.08.2022)
description: >-
  MHI driver for the parallel-port MAS decoder - sibling build of
  mhimasstd 1.5 (pro variant drops the "std" suffix; the codec and
  ABI are the same 10-function MHI API).
timestamp: 2026-10-15T09:45:00Z
---

# mhimaspro_1.5

Sibling of mhimasstd_1.5 - same SAS/C codebase, same hunk layout,
same XpksSub-style MHI vectors.  See ../mhimasstd_1.5.library/okf/
for the full decode; this bundle records the version-specific delta.

## Delta vs mhimasstd 1.5

- name/idstring: mhimaspro_1.5 (26.08.2022), revision field 5 in DataTab
- mhimasstd 1.6 additionally: CIAB_DDRA clear changed to
  `&= 0xf8` (preserves low-3 DDR bits) - real behaviour fix
- mhimaspro_*: 4-byte larger .text (minor code drift)

## Status

FULL - source/ builds a valid library (cloned from the
mhimasstd_1.5 reconstruction, version-adjusted).
