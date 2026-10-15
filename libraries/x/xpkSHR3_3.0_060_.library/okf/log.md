---
file: log
---
# Work log

- 2026-10-15: single-hunk AUTOINIT xpkSHR3 3.0 (060); mnemonic
  transcription (raw head 0-0xac + tail data 0xdf0-0x1028),
  fixup splices 23-entry RELOC32 tail. BYTE-IDENTICAL.
- machine68k oracle (xpkSHR3 020 harness, AttnFlags=0xffff,
  CPUType.M68020 — no M68060 type exists and the 060 codegen uses
  only <=020 instrs): init, 10 vectors, info/mode table, real
  pack/unpack round-trips both decoder flavours, multi-chunk
  flag-2 continuation round-trip, flag>=3 reject, ctx reinit/free,
  expunge. RUNTIME-IDENTICAL (0 invalids). Logs identical to the
  020 build modulo shifted data/vector addresses and the
  'Shrink 020-060 V3.0' long name.
