# Log

- 2-hunk layout; mid-hunk extended resident @h0+0x94 (name ->h0+4);
  h1 DATA content 8 longs but header mem size 0x34 longs (uninit tail).
- Verbatim .byte emission of both bodies + tail splice fixup:
  BYTE-IDENTICAL (5844B, md5 90a9edad5c4f7e7f9eb0ed1c192b0189).
- Oracle (adapted from 5.1): MatchTag scan + InitData header fill +
  full 10-vector probe on orig and rebuild.
  RUNTIME-IDENTICAL (1704 deterministic invalids; open cnt=1,
  vectors -36..-54 -> 0x80, -60 -> 0x8000000c, close underflow
  cnt=65535, expunge -> 0).
