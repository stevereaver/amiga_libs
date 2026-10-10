---
type: Finding
title: Differences vs freeanim 40.29
description: 40.9 is a working library; 40.29 is an unloadable stub.
timestamp: 2026-10-10T18:00:00Z
---

# Differences vs freeanim 40.29

- 40.29: init + all vectors = shared `moveq #0,rts`; cannot be
  installed (init failure).  40.9: full lifecycle routines.
- 40.29: no InitStruct, dataSize 0x2a.  40.9: InitStruct present,
  dataSize 0x26 (seglist slot at +0x22).
- 40.29 flags 0x80; 40.9 flags 0x81 (+RTF_COLDSTART).
- ID strings differ in style and date: `freeanim 40.29 (1.4.94)` vs
  `freeanim.library 40.9 (11.8.95)` — the later build carries the
  earlier *version number* and vice-versa (40.9 dated 1995, 40.29
  dated 1994), i.e. version/revision chronology is inconsistent.
- Neither build exports any public function.
