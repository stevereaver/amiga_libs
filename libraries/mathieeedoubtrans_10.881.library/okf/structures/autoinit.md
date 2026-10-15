---
type: Structure
title: AUTOINIT / RomTag layout
description: Code-hunk header layout of mathieeedoubtrans.library.
---

# AUTOINIT layout (mathieeedoubtrans.library)

Code hunk, offsets as shipped:

| off | contents |
|-----|----------|
| 0x00 | `rts` (bare executable entry -- no `moveq #-1,d0`) |
| 0x02 | RomTag: matchword 0x4afc, matchtag->0x02, endskip->end of hunk |
| 0x0a | flags 0x80 (RTF_AUTOINIT), version 45, type 9 (NT_LIBRARY), pri 0 |
| 0x0e | rt_Name -> 0xf5, mid-string inside the NoFPU path (name carved out of the path tail) |
| 0x12 | rt_IdString -> "MDT 10.881" |
| 0x16 | rt_Init -> InitTable at 0x1c |
| 0x1c | InitTable: dataSize=0x3c, funcTable=0x30, dataTable, initFunc |
| 0x2c | seglist cell (patched by initfunc) |
| 0x30 | function table: `0xffff`, word offsets relative to 0x30, `0xffff` |

Word-offset format: the leading -1 marks word offsets; each word is the
function's offset from the table base; -1 terminates. Relocations only on
the RomTag/InitTable pointer fields.
