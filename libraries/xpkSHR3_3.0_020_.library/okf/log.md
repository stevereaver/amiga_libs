---
file: log
---
# Work log

- 2026-10-15: single-hunk AUTOINIT xpkSHR3 3.0 (020); mnemonic
  transcription (raw head 0-0xac + tail data 0xdc2-0xff8),
  fixup splices 23-entry RELOC32 tail. BYTE-IDENTICAL.
- machine68k oracle (SHRI harness; word-functab autodetect +
  AttnFlags=0xffff + bounded calls): init, 10 vectors,
  info/mode table, incompressible -17 bail, real pack
  (mode 60 -> 22B) and full unpack round-trips for both
  decoder flavours, -26 header reject, ctx -48 re-init / -42
  free, deferred+real expunge. RUNTIME-IDENTICAL (0 invalids).
