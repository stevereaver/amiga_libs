---
type: Log
title: Reconstruction log
---
# Log

- Parsed AUTOINIT tables: word-offset functab (10 vectors),
  datatab, dataSize 0xaa.
- Decoded LibInit's runtime descriptor filler (XpkMode@+0x80,
  XpkInfo@+0x28) — same convention as V1.1.
- Identified the `bclr/bset/btst #8,lib_Flags` byte-op wrap
  quirk: bit 8 -> bit 0 (LIBF_SUMMING) used as the deferred-
  expunge flag instead of LIBF_DELEXP; fixed in V1.1.
- Reconstructed pack/unpack machines faithfully incl. the
  >= / > bound-check asymmetry and asymmetric insize limits.
- Built with m68k-amigaos-gcc two-pass functab; all 10
  vector offsets verified; LVO inventory matches (Remove,
  FreeMem only).
- Host test: 39644 round-trips on compressible data plus
  ~2300 on random data, 0 failures; -17 rejects on
  incompressible input are shipped semantics.
- Inconsistencies filed in Plane (AMIGALIBS-39).
