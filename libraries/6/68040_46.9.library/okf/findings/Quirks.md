---
type: Finding
title: Quirks and open questions
---

# Quirks — 68040.library 46.9 (Lynxx)

- **Retracted: "+2 name pointers".** An earlier analysis claimed
  `OpenLibrary("060.library")` and `LoadSeg("bs:68040mmu.library")`
  (offsets +2 into the stored strings). Oracle logs show the full
  names — both `lea`s target the string starts (+0x2c/+0x3a). The
  Phase5 68040dummy 44.1 does have a genuine +7 variant of this
  pattern; this binary does not.
- **exec LVO -810 = TaggedOpenLibrary(tag)** (exec_lib.i; the older fd
  still calls it execPrivate17). Called unconditionally with tag=4 —
  on an exec without that vector this jumps into the gap between
  exec's jump table and base. The systems this loader targets
  (OS 3.1.4/3.2-era, exec V45+) implement it; tag 4 yields the
  dos.library base used for the LoadSeg calls.
- **Probe = `movec pcr` (control reg 0x808)** under a patched
  illegal-instruction vector (installed via `movec vbr,a0` then
  `move.l a1,$10(a0)`): returns 1 only on the 68060 — the classic
  040/060 distinguisher.
- **Fault handler skips 4 bytes:** `addq.l #4,2(a7)` adjusts the
  stacked PC past the *entire* 4-byte `movec pcr` (the binary encodes
  this as `58af 0002` — an `addq.l` to memory, which gas spells
  `addql` here). It then does `moveq #0,d0; rte`, landing on the
  probe's vector-restore + rte tail.
- **Preload-then-die on real 68040:** after LoadSeg+InitResident the
  init drops into `moveq #0,d0` — the loader always reports failure
  so exec discards this stub; the freshly initialized resident keeps
  running. On the 68060 path init returns the base and `lb_OpenLib`
  holds the real `68060.library` base that LibOpen hands out.
- **InitResident ABI quirk:** the seglist is passed in d0, not d1 as
  the published signature requires; d1 at that point holds a stale
  LoadSeg-name pointer. Works because InitResident only uses the
  seglist on the failure path.
- **LibOpen repairs ln_Type:** it stores `#9` (NT_LIBRARY) into
  `ln_Type` on every open — the InitStruct table leaves it 0, so the
  first open is what actually tags the node.
- No user LVOs; OpenCnt is never decremented (Close is a null stub
  shared with Expunge/ExtFunc) — permanent resident.
