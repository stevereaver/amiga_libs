---
type: Structure
title: iff.library 22.1 base/layout
tags: [layout]
timestamp: 2026-10-15T00:00:00Z
---
# iff.library 22.1 structures

- Library base: dataSize 0x3c (36-byte exec header + 24 private
  bytes for dosbase/state: dosbase@0x26, scratch list@0x2e,
  opencnt@0x20, flags bit3 DELEXP@0x0e).
- iff handle: private, BMHD/CMAP/BODY/CAMG/DLTA-aware;
  xpkmaster.library used for compressed chunks (OpenLibrary'd
  via OldOpenLibrary -408 in OpenIFF when the FORM payload is
  not directly readable).
- RomTag is the CHW variant: an extra relocated longword at +6
  (points into code, +0x1f0) pushing flags/version/type/pri to
  +0x0a; InitResident still finds the AUTOINIT table via +0x16.
