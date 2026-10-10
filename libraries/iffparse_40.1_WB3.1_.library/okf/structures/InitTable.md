---
type: Structure
title: InitTable / AUTOINIT
description: RomTag, InitTable and the word-offset function table.
timestamp: 2026-10-10T18:00:00Z
---

# InitTable

RomTag at text+0x04: `RTF_AUTOINIT` (0x80), version 40, NT_LIBRARY,
pri 0.  `rt_Init` → +0x48:

```
dc.l 0x44        ; dataSize  = sizeof(struct IFFBase)
dc.l functab     ; -> text+0x58
dc.l 0           ; no InitStruct data
dc.l init        ; -> text+0xb6 (LibInit)
```

## Function table format

First word `-1` selects word-offset mode: each entry is a 16-bit
offset **from the table start** (not from text base, not from its
own position), terminated by `-1`.  45 entries total:

- slots 0-3: Open, Close, Expunge, ExtFunc(LibNull)
- slots 4-44: the 41 iffparse LVOs in NDK FD order
  (`##bias 30`, `##bias 102` gap after PopChunk)

The reserved LVO -96 slot and ExtFunc (-24) both point to the same
`moveq #0,d0 / rts` stub at 0x1ba.

## Reconstruction note

gas cannot emit `dc.w extern_func - local_label` across objects —
it produces RELRELOC16 (target minus *entry position*), corrupting
the table.  The build therefore links a dummy table first, reads
final function addresses with `nm`, and `genfunctab.py` emits
literal `.word` values.  See `source/Makefile`.
