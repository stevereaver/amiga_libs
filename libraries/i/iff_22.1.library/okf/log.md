---
type: Log
title: Work Log
description: Chronological journal of analysis sessions.
---

# Log

## 2026-10-15
- Transcribed via tools/transcribe.py; emitted body 0x00-0xf7 raw
  (RomTag/strings/functab/datatab — objdump's instruction decodes of
  the string region did not round-trip); code region 0xf8+ as asm.
- fixup.py splices the original 10-entry RELOC32 tail; second
  all-zero DATA hunk emitted via a `.data` section.
- `make` -> BYTE-IDENTICAL (md5 3b33b332b5479ec3e0efed5c81cf5681).
- work/oracle.py adapted from iff_22.3 harness: generic exec/dos/xpk
  traps; module entry + initfn + all 25 vectors + open/expunge-defer/
  close lifecycle -> RUNTIME-IDENTICAL.
- Delta vs 22.3 confirmed: +14B = dos Seek(fh,0,-1) filesize probe
  in the xpk-decompress path; -2B alignment pad.
