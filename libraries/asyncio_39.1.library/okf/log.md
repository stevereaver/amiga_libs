---
type: Log
title: asyncio 39.1 work log
---

- Parsed: CODE 0xc1c + BSS 5 longs; relocs h0->h0 (24: 17 functab
  + 7 operands), h0->h1 (10 BSS refs).
- Resident at +0x8c -> InitTable at +0x4c -> functab at +0x04,
  initfn +0x106; idstring 'asyncio.library 39.1 (7.6.97)'.
- Verbatim transcription byte-identical; fixup.py rebuilds the
  2-hunk header and emits the BSS hunk tail-only (tag+size+END).
- Oracle exercises all 17 vectors + deferred/real expunge;
  identical on original and rebuild.
