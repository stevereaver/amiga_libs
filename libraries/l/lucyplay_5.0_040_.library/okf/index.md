# lucyplay_5.0_040_.library

"lucyplay 5.0 (17.02.2001) 68040" — 68040 build of lucyplay 5.0.
5960B.  Same family as lucyplay_5.0 (AMIGALIBS-387) and
lucyplay_5.0_020_ (AMIGALIBS-388).

- Flat single CODE hunk (0x5af longs), AUTOINIT, DREL16 tail.
- Resident @h0+0x180; InitTable@h0+0x170: dsize 0x52,
  ftab@h0+0x1d4 (26 abs-long vectors), dtab@h0+0x240,
  initfn@h0+0xe0.
- initfn returns 0 under the 68000-style stub harness (same
  processor/dependency gate as the 020 build); all 26 vectors
  still execute.
