# log

- IRA disasm + objdump decode of the whole 1748-byte code hunk.
- Identified as "Executable Explode Wedge V6.0.64" — intermediate
  between done siblings 5.6.29 (AMIGALIBS-era) and 7.0.
- C side adapted from explode_5.6.29 source (same wedge skeleton)
  + the exec>=37 NewLoadSeg second patch from the 7.0 flow.
- Decoder/stub/checker span transcribed verbatim from objdump;
  after fixing `moveal 0x4,a6` absw-vs-absl (forced .word 0x2c79)
  and a tab2 row-boundary transcription error, the full
  _ExpMark.._TagEnd span is byte-identical (0x49e bytes).
- Header/functab/datatab byte-identical modulo relocated pointers.
