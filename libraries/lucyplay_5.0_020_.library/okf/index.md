# lucyplay_5.0_020_.library

"lucyplay 5.0 (020)" — 68020+ build of lucyplay 5.0. 5856B.
Same family as lucyplay_5.0 (AMIGALIBS-387).

- Flat single CODE hunk (0x59a longs), AUTOINIT, DREL16 tail.
- Resident @h0+0x17c; InitTable@h0+0x16c: dsize 0x52,
  ftab@h0+0x1d0 (26 abs-long vectors), dtab@h0+0x23c,
  initfn@h0+0xe0.
- initfn returns 0 under the 68000-style stub harness (likely a
  processor/dependency gate); all 26 vectors still execute.
