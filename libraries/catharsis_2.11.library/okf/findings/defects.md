---
file: defects
---
# Findings

- Vector -30 is a relocated ZERO: the functab slot at h1+0x68
  stores 0 and is covered by a RELOC32->h0 entry, so the vector
  resolves to CODE+0 — a real function (link a5,#-6), not a
  reserved hole or -1 stub. (hgrexxsupport had a true unrelocated
  NULL hole instead.)
- Private open counter at lib+0x22 (word), not the standard
  lib_OpenCnt@0x20. Open/Close/Expunge all use a6@(34).
- Deferred-expunge flag is bit3 of lib+0xe (flags): Open clears
  it, Expunge sets it when the resource sweep (h0+0x91c) reports
  live entries or opencnt>0; Close tail-calls Expunge at cnt 0.
- BSS hunk holds only 16B: execbase, GfxBase, IntuitionBase,
  libbase — code reaches them through abs-long operands relocated
  against h2 (e.g. `moveal (4).l,a6` -> GfxBase).
- Init failure path: if intuition.library v33 fails to open,
  CloseLibrary(gfx) then initfn returns 0 (lib expunges itself).
- Rebuild: BYTE-IDENTICAL (make), oracle diff clean, invalids 0.
2026-10-15
