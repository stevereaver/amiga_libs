---
file: log
---
# Work log

- 2026-10-15: single-hunk AUTOINIT xpkSHR3 3.0 (020); mnemonic
  transcription (raw head 0-0xac + tail data 0xdc2-0xff8),
  fixup splices 23-entry RELOC32 tail. BYTE-IDENTICAL.
- machine68k oracle (xpkSHRI harness + word functab autodetect +
  AttnFlags=0xffff + bounded calls): init, 10 vectors, info/mode
  table, real pack/unpack round-trips both decoder flavours,
  multi-chunk flag-2 continuation round-trip, flag>=3 reject,
  ctx reinit/free, expunge.
  RUNTIME-IDENTICAL (0 invalids). Plane AMIGALIBS-319.
