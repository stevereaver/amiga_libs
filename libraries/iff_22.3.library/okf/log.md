---
type: Log
title: Work Log
description: Chronological journal of analysis sessions.
---

# Log

## 2026-10-15
- Transcribed via tools/transcribe.py; emitted body 0x00-0xf5 raw
  (RomTag/strings/functab/datatab — objdump's instruction decodes of
  the string region were unround-trippable: decimal-vs-hex
  displacement canonicalization); code region 0xf8+ as asm.
- fixup.py splices the original 10-entry RELOC32 tail; second
  all-zero DATA hunk emitted via a `.data` section.
- `make` -> BYTE-IDENTICAL (md5 edfc75560189f128a36a1d049bb4178d).
- work/oracle.py adapted from iff_23.2 harness: generic exec/dos/xpk
  traps; module entry + initfn + all 25 vectors -> RUNTIME-IDENTICAL.
