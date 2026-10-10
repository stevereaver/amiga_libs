---
type: Structure
title: Library base layout
description: struct Library fields actually touched by mathieeedoubtrans.library.
---

# Library base layout (mathieeedoubtrans.library)

Standard `struct Library`, dataSize = 0x3c (InitTable longword 0).

| offset | field | use |
|--------|-------|-----|
| 0x00 | lib_Node.ln_Succ/ln_Pred | unlinked on expunge (4 longwords of node) |
| 0x08 | ln_Type/Pri/Name | set by AUTOINIT |
| 0x0e | lib_Flags | InitStruct sets 0x06; bit 3 = LIBF_DELEXP |
| 0x10 | lib_NegSize | bytes of jump-vector region before base |
| 0x12 | lib_PosSize | bytes of base itself |
| 0x14 | lib_Version | 45 |
| 0x16 | lib_Revision | 881 (0x0371) via InitStruct word |
| 0x18 | lib_IdString | "MDT 10.881" |
| 0x20 | lib_OpenCnt | word, inc/dec in Open/Close |

## InitStruct byte stream (datatab)

`a0 0e 06 00 90 16 03 71 00 00` = INITBYTE lib_Flags(0x0e)=0x06,
INITWORD lib_Revision(0x16)=0x0371, terminator.

## Seglist cell

A longword inside the code hunk at text+0x2c holds the seglist passed to
the init routine (a0); returned by expunge/close-expunge.
