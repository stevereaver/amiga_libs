---
file: defects
---
# Findings

- initfn stores the 3 opened dep lib bases at name+4/+8/
  +0xc — i.e. inside the dep-name strings themselves
  ("intuition.library" etc. get clobbered after open).
  Self-modifying quirk; bases are effectively thrown
  away (vectors re-OldOpenLibrary on demand instead).
- initfn SetFunction-patches exec FreeMem (LVO -210)
  under Forbid/Permit with a 'PPMM'-tagged hook —
  same hook mechanism as powerpacker 020+ 37.0
  (AMIGALIBS-394). Side-effect on the whole system,
  never removed.
- BSS hunk is only 16 bytes (4 longs); header table
  reserves 4 longs but the BSS hunk's own size field in
  the file is 0.
- Dep strings dos/intuition/graphics.library are inline
  in the CODE hunk between InitTable and initfn.
- Runtime: ~185k invalid accesses counted — the crunch
  core walks raw buffers; deterministic (identical count
  on rebuild).
