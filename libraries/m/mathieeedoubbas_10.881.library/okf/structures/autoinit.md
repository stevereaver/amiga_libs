---
type: Structure
title: AUTOINIT / RomTag layout
description: Code-hunk header layout of mathieeedoubbas.library.
---

# AUTOINIT layout (mathieeedoubbas.library)

Code hunk, offsets as shipped:

| off | contents |
|-----|----------|
| 0x00 | `rts` (bare executable entry -- no `moveq #-1,d0`) |
| 0x02 | RomTag: matchword 0x4afc, matchtag(0x04)->0x02, endskip(0x08)->end of hunk (0x230) |
| 0x0c | flags 0x80 (RTF_AUTOINIT), version 45, type 9 (NT_LIBRARY), pri 0 |
| 0x10 | rt_Name -> library name string at 0xeb (tail of the "Libs:NoFPU/..." path) |
| 0x14 | rt_IdString -> "MDB 10.881" at 0x103 |
| 0x18 | rt_Init -> InitTable at 0x1c |
| 0x1c | InitTable: dataSize=0x3c, funcTable=0x30, dataTable=0x54, initFunc=0x5e |
| 0x2c | seglist cell (patched by initfunc) |
| 0x30 | function table: `0xffff`, word offsets relative to 0x30, `0xffff` |

Word-offset format: the leading -1 marks word offsets; each word is the
function's offset from the table base; -1 terminates. Relocations only on
the RomTag/InitTable pointer fields.
