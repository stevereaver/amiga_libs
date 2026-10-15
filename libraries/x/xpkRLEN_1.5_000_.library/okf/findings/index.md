# Findings

- [RebuildDelta.md](RebuildDelta.md)
- [EndSkipZero.md](EndSkipZero.md) — rt_EndSkip is literal 0
- [InlenCeiling.md](InlenCeiling.md) — packer ceiling is OutBuf+InLen;
  xsp_OutBufLen ignored; incompressible and zero-length input -> -17
- [Decoder80x128.md](Decoder80x128.md) — 0x80 token emits 128 bytes
- [StubIsNullVector.md](StubIsNullVector.md) — entry stub doubles as
  all four dead vectors via negative functab offsets
