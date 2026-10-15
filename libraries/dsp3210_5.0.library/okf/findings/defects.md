---
type: Findings
title: dsp3210 5.0 quirks
---

# Findings / quirks

- Same skeleton as the 4.0 sibling: single CODE hunk, COLDSTART
  resident at +0x04, `moveq #0,d0/rts` entry stub, word-offset
  functab (`ffff` marker … `ffff`), only 5 RELOC32 entries —
  all inside the resident struct (matchtag/endskip/name/id/init).
  Every other internal reference is pc-relative, so the DSP
  routines and the d32 data ride unreloc'd inside the code hunk.
- Version bookkeeping is inconsistent: resident rt_Version=5 and
  initfn writes lib_Version=5, and the idstr says `5.0`, yet the
  idstr date `(4.8.2021)` *predates* the 4.0 build's
  `(15.7.2021)` — the 5.0 line was apparently branched/dated
  earlier or the date string was not bumped.
- **Error codes renumbered** vs 4.0 (observed as immediate
  operands and in oracle output): -2→-3, -3→-5, -4→-7, -5→-9,
  -10→-11, -20→-21, -21→-23, -30→-31 — i.e. the mixed set of
  4.0 moved wholesale to the "odd negative" scheme already
  documented for the later dsp3210.h headers. Oracle-visible
  effects: -48/-78 now return -7 (was -4) and DSPRelocate(-36)
  returns -5 (was -3) on the minimal valid blob.
- **One real code change** at h0+0xac0 (+14 bytes): the call to
  the internal vector -42 of the secondary base (`a2@(38)`)
  was reworked to an out-parameter protocol — 5.0 reserves a
  stack long, passes its address in a2, and uses the stored
  result/a1 depending on the d0 status, where 4.0 passed only
  a0=a2 and took d0 directly.
- The -60 vector (list walker at +0xbcc) returns **0** instead
  of **-1** on invalid arguments — a silent contract change.
- Cosmetic: +2 pad bytes after the DSP register-name table
  (h0+0xf7a) keep the following routine long-aligned (the +14
  insertion would otherwise leave it at an odd mod-4 offset).
- `cmpiw #36,a6@(20)` guards an exec -642 call — the code
  conditionally uses a v36+ exec feature.
