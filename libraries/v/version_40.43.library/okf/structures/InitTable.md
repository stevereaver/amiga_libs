---
type: Structure
title: InitTable / AUTOINIT
description: RomTag, InitTable and the word-offset function table.
---

# InitTable

RomTag at text+0x04: `RTF_AUTOINIT` (0x80), RT_VERSION 40,
NT_LIBRARY (9), pri 0.  `rt_Init` → text+0x48:

```
dc.l 0x2a        ; dataSize  = sizeof(struct VersionBase)
dc.l functab     ; -> text+0x58
dc.l 0           ; no InitStruct data
dc.l init        ; -> text+0x64 (LibInit)
```

## Function table format

First word `-1` selects word-offset mode: each entry is a 16-bit
offset **from the table start**, terminated by `-1`.  Four entries:

| slot | LVO | offset | target |
|-----:|----:|-------:|--------|
| 0 | -6 Open | 0x0020 | text+0x78 |
| 1 | -12 Close | 0x0028 | text+0x80 |
| 2 | -18 Expunge | 0x0062 | text+0xba (null stub) |
| 3 | -24 ExtFunc | 0x0062 | text+0xba (same stub) |

## Reconstruction note

gas cannot emit `dc.w extern_func - local_label` across objects, so
the build links a dummy table first, reads final addresses with
`nm`, and `genfunctab.py` emits literal `.word` values
(pass-2 Makefile, copied from iffparse).
