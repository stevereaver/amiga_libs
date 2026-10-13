# ksort.library — work log

- Parsed hunk structure: 4 hunks CODE 536B / BSS 64B /
  CODE 1400B / CODE 60B; imports dos+intuition+graphics;
  absolute-long functab (11 vectors); dataSize 0x2a.
- Functab initially misread as starting at 0x84; corrected to
  0x8c — lifecycle vectors are standard, NOT rotated.
- Identified LibInit/Open/Close/Expunge + null stub at
  h0+0xdc/0x150/0x15e/0x172/0x214; InitTable at 0x7c
  (rt_EndSkip points there too), datatab at 0xbc.
- hunk2 = 7 identical (array:d0,count:d1) wrappers + 7
  recursive quicksort workers + `jmp` tail stub; hunk3 =
  stricmp comparator (stack args, C convention).
- Emulated in machine68k: mapped all vectors, verified every
  sort produces correctly ordered output; confirmed the
  string sort's i<j-bounded scans and stricmp comparator.
- Found expunge defects: `tst.w 0x20(a5)` wild opencnt read,
  CloseLibrary on name strings, `move.l d2,0` wild write to
  absolute 0, CloseLibrary-residue return.
- Found u32 defect: unsigned index compares cause a wild
  j-cursor walk + memory corruption when a partition
  self-swaps at index 0 (triggered by any qs(a,0,1) call —
  e.g. descending-4/10 inputs; n=6/8/20 escape by luck).
- Wrote C reconstruction (7 variants, ULONG indices in qs_u32
  for defect fidelity) + asm AutoInit skeleton (all lifecycle
  quirks verbatim).  Verified identical sorted output and
  identical corruption pattern vs the original across
  directed cases and randomized sweeps.
