---
type: Log
title: nonvolatile 40.36 work log
---

- Single hunk, 2 RomTags (AUTOINIT lib + AFTERDOS deinstall);
  InitTable@0x1e; word-offset functab@0x2e, 11 vectors.
- Verbatim .text; byte-identical first pass.
- Oracle extended with word-functab handling; identical
  over init/11 vectors/expunge.
