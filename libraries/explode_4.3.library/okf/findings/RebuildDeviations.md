---
type: Finding
title: explode 4.3 verbatim rebuild notes
tags: [rebuild, quirks]
timestamp: 2026-10-15T04:04:39Z
---
# Rebuild deviations / transcription notes (verbatim asm)

- Header/data region 0x00-0xc1 emitted raw: RomTag, both name
  strings, InitTable, absolute functab (5 entries + `ffffffff`),
  datatab (e0/d0/c0 off16 opcodes incl. a relocated long @0xa0 and
  word @0xba).
- initfn quirks exercised by the oracle: it inspects the *current*
  dos -0x96 vector — `cmpiw #0x4ef9` for jmp-form vectors, else a
  BCPL `0x70`/`0x6000` (moveq/bra) stub form — and tail-patches the
  hook's return-jump target accordingly; on jmp-form the hook entry
  is offset +2 (0x174+2 = 0x176 is what gets installed).
- Alert(0x00038007) is the dos-OpenLibrary failure path.
- `explode_h0.s` uses literal operands only; the original 16-entry
  RELOC32 trailer is spliced by fixup.py.
