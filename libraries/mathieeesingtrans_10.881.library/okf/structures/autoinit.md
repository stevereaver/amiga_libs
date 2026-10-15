---
type: Structure
title: AUTOINIT / RomTag layout
description: Code-hunk header layout of mathieeesingtrans.library.
---

# AUTOINIT layout (mathieeesingtrans.library)

Code hunk, offsets as shipped:

| off | contents |
|-----|----------|
| 0x00 | `rts` (bare executable entry -- no `moveq #-1,d0`) |
| 0x02 | RomTag: matchword 0x4afc |
| 0x04 | rt_MatchTag -> 0x02 |
| 0x08 | rt_EndSkip -> 0x244 (end of hunk) |
| 0x0c | rt_Flags 0x80 (RTF_AUTOINIT), rt_Version 45, rt_Type 9 (NT_LIBRARY), rt_Pri 0 |
| 0x10 | rt_Name -> **0x109** (tail of the NoFPU path string!) |
| 0x14 | rt_IdString -> 0x123 "MST 10.881" |
| 0x18 | rt_Init -> InitTable at 0x1c |
| 0x1c | InitTable: dataSize=0x3c, funcTable=0x30, dataTable=0x5e, initFunc=0x68 |
| 0x2c | seglist cell (patched by initfunc) |
| 0x30 | function table: `0xffff`, 21 word offsets relative to 0x30, `0xffff` |
| 0x5e | InitStruct stream `a0 0e 06 00 90 16 03 71 00 00` |
| 0x68 | init routine |
| 0x92 | LibOpen .. 0xfc end of framework code |
| 0xfe | `"Libs:NoFPU/mathieeesingtrans.library\0"` — rt_Name lands at +11 |
| 0x123 | `"MST 10.881\0"` + 2 pad bytes |
| 0x130 | IEEESPPow block .. 0x243 stubs+pad |

Word-offset format: the leading -1 marks word offsets; each word is the
function's offset from the table base; -1 terminates. Relocations only on
the RomTag/InitTable pointer fields.
