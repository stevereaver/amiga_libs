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
  under Forbid/Permit with a 'PPMM'-tagged hook @h0+0xa58
  (cmpi.l #'PPMM',-8(a1); old vec @h0+0xa54) — same hook
  mechanism as 35.344 (AMIGALIBS-397) and powerpacker 020+
  37.0 (AMIGALIBS-394). Side-effect on the whole system,
  never removed.
- BSS hunk is only 16 bytes (4 longs); unlike sibling
  35.344 (whose BSS hunk record carries size 0 in the
  file while the header table reserves 4), this build
  writes 4 in both places.
- 23 vectors vs 22 in 35.344: new tail entry -138 ->
  h0+0xee8 packs (src,len,end) + a2 into a caller-supplied
  context before tail-calling the core.
- Dep strings dos/intuition/graphics.library are inline
  in the CODE hunk between InitTable and initfn.
- Runtime: ~185k invalid accesses counted — the crunch
  core walks raw buffers; deterministic (identical count
  185452 on rebuild).
