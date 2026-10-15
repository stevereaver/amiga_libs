# Log

- 2-hunk layout; mid-hunk extended resident @h0+0x96 (name ->h0+4);
  h1 DATA content 8 longs but header mem size 0x34 longs (uninit tail).
- Verbatim .byte emission of both bodies + tail splice fixup:
  BYTE-IDENTICAL (6128B, md5 1e9ddde1673a1bf915fe04aa1f8ba92e).
- Oracle (unchanged from 5.17, itself from 5.7/5.1): MatchTag scan +
  InitData header fill + full 10-vector probe on orig and rebuild.
  RUNTIME-IDENTICAL (1704 deterministic invalids; open cnt=1,
  vectors -36..-54 -> 0x80, -60 -> 0x8000000c, close underflow
  cnt=65535, expunge -> 0).
