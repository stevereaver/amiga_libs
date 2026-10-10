---
type: Log
title: Work Log
description: Chronological journal of analysis sessions. Newest first.
---

# Log

## 2026-10-10
- Parsed module: single CODE hunk, RomTag ver 1, InitTable
  dataSize 0x30 + InitStruct data, 20 absolute vectors.
- Decoded all vectors: five setters into code-hunk globals g1-g5,
  five getters (g3 returned raw), a tail-call into *(g3+12), a
  method call *(g3+100) writing a scratch buffer, two string
  copies from g3+104/+108, two -2-offset pointer reads at
  g3+112/+116.
- Private DELEXP flag at base+34 bit 3 (not lib_Flags).
- Reconstructed fully in assembly; `make` builds; semantics
  verified vector by vector.
