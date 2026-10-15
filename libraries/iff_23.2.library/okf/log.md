---
type: Log
title: Work Log
description: Chronological journal of analysis sessions.
---

# iff.library 23.2 work log

- Disassembled 3068B CODE hunk; word-offset functab (25 vectors);
  module-entry sign-on banner identified.
- Generated verbatim asm via work/transcribe.py; manual fixes:
  pc-indexed jumps at 0x93x/0x9cx forced to .short (gas picked wrong
  encodings); string/inline-data regions re-emitted as raw bytes.
- fixup.py splices the original 10-entry same-hunk RELOC32 tail.
- `make` → BYTE-IDENTICAL (md5 3f3562b6bfc6288498f8f88b3ff504f4).
- work/oracle.py: machine68k harness, generic exec/dos/xpk vector
  traps; exercises module entry, AUTOINIT initfn, and all 25
  vectors → RUNTIME-IDENTICAL orig vs rebuild.
