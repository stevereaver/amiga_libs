---
type: Log
title: Work Log
description: Chronological journal of analysis sessions for this library. Newest first.
---

# Log

## 2026-10-14

- Parsed hunk: single CODE hunk, 0x2f2 longwords (3016 B) at file
  0x20; RELOC32 group + HUNK_END.
- RomTag AUTOINIT v1 at code+4 (`rt_EndSkip=0` quirk), InitTable
  @0x64 (dataSize 0x26), word-offset functab @0x94 (10 vectors,
  backward -0x94 offsets for the two null entries).
- Resolved all vectors against the xpkDUKE/xpkNUKE 1.8 skeleton:
  lifecycle + XpkSubFree shared free, XpksPackerInfo, Pack/UnpackChunk,
  null PackReset.
- Decoded pack workspace layout (distance-class bounds,
  256-long histogram, hash-head table sized `0x100<<submode`),
  mode records, XpkInfo block, password-hash helper @0xa74.
- Reconstruction: `work/genasm.py` transcribed the whole hunk to
  `source/xpkLIN2.s`; `work/fixup.py` iterated .short raw-emits for
  gas-canonicalized encodings (converged after 13 patches).
  `make` -> BYTE-IDENTICAL (MD5 8b941020dcb8451eefe40c09be5f6993).
- `work/oracle.py` (machine68k): full lifecycle + all vectors +
  pack/unpack of 20 fixtures (streamsO vs streamsR byte-identical),
  failure paths -7/-14/-17/-32. orig vs rebuild logs identical:
  RUNTIME-IDENTICAL.
