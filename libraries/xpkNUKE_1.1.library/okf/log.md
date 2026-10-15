---
type: Log
title: xpkNUKE 1.1 work log
---

- Two-hunk AUTOINIT lib (CODE 0xaf4 + DATA 0x140); initFn
  copies DATA into the lib node and self-relocates 8 pointers.
- Verbatim two-source transcription; fixup splices original
  RELOC32 tails; byte-identical.
- Oracle does real pack->unpack round-trips on 12 payload
  shapes + chained/realloc/allocfail/garbage edges — identical
  original vs rebuild.
