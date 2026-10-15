---
file: defects
---
# Findings

- Layout quirk: 4 hunks where most Amiga libs use 1-2 —
  InitTable alone in h2 DATA, functab+strings alone in h3
  CODE. RomTag's rt_Name/rt_IdString/rt_Init all point
  into OTHER hunks (h3/h2), so the resident only resolves
  after all hunks are loaded+relocated; standard for disk
  loadseg but unusual vs packed-resident builds.
- Vector -24 points at the anti-run stub (h0+0):
  `moveq #0,d0;rts` — returns 0, harmless.
- Open's context-relocate path reads absolute longword
  0x2e (via a zeroed context slot) when deciding whether to
  patch the copied segment table — a leftover of a
  multi-segment scheme; h1's count field is 0 so the branch
  is skipped after a benign low-mem read.
- rt_EndSkip = h0+0x1e points at 2 pad bytes (0x0000)
  between the resident and initfn @h0+0x20.
- Oracle: open/close/expunge/worker all deterministic,
  0 invalid accesses; expunge with OpenCnt>0 correctly
  refuses (flags 0xe = DELEXP set, returns 0).
