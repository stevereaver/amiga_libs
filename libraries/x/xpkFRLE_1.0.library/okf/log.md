---
type: Log
title: xpkFRLE 1.0 reverse-engineering log
---

# Log

- Parsed single CODE hunk (0x3e8 bytes): entry stub, RomTag,
  strings, InitTable 0x26/functab@0x66/datatab@0x7e/init@0x9e.
- Disassembled framework: textbook Open/Close/Expunge,
  LIBF_DELEXP, SysBase at 4.W, Remove -252 / FreeMem -210.
- Decoded functab: 10 word-offset entries relative to the -1
  marker; -24/-42/-48/-60 share the `moveq #0` stub at +0x10a.
- Recovered the encoder's four-phase literal state machine and
  the 15+7*16 unrolled run counter; proved via path analysis
  that the literal budget max lands on exactly 128 bytes.
- Recovered the computed-goto decoder; confirmed xsp_OutLen is
  written (unlike the 1.2 rebuild).
- Stream format confirmed identical to FRLE 1.1/1.2.
- Reconstructed C source (bounded reads), two-pass generated
  functab, m68k-amigaos-gcc -m68000 build -> valid hunk library.
- Host round-trip: 40,000 randomized inputs + boundary cases
  (runs to 129, literals to 128, empty/1/2-byte inputs) — all pass.
