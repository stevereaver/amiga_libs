---
type: Log
title: mpega 2.4 (PPC) work log
---

- Parsed hunk file: CODE 0x964 + DATA 0x230, three RELOC32 groups.
- Found Resident inside DATA hunk at +0x100; InitTable at h1+0;
  functab 11 absolute longs at h1+0x10; byte-command InitData at
  h1+0x11c.
- Verbatim transcription byte-identical on first build; fixup.py
  restores 2-hunk structure + original reloc tails.
- Oracle: 2-hunk loader, embedded-resident scan, byte-command
  InitStruct emulation, dos/ppc stubs; init + 11 vectors +
  open/close/expunge identical between original and rebuild.
