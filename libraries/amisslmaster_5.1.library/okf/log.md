# Log

- 2-hunk layout; mid-hunk extended resident @h0+0x94 (name ->h0+4).
- Verbatim .byte emission of both bodies + tail splice fixup:
  BYTE-IDENTICAL (5660B).
- Oracle: MatchTag scan + InitData header fill + full vector probe.
  RUNTIME-IDENTICAL (1704 deterministic invalids).
