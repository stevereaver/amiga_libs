---
type: Structure
title: InitTable
---

# AUTOINIT tables

RomTag (hunk+4): RTC_MATCHWORD, RT_ENDSKIP -> endmodule,
RTF_AUTOINIT, version 37, NT_LIBRARY, pri 0.

InitTable (hunk+0x1e):
- dataSize 0x2a
- function table (hunk+0x2e): 8 absolute longwords
  Open/Close/Expunge/Null/GRDispatch/GRArm/GRCall6/GRCall7,
  terminated by **two** -1 longwords
- data table (hunk+0x52): InitStruct stream --
  INITBYTE ln_Type=NT_LIBRARY, INITLONG ln_Name,
  INITBYTE lib_Flags=6, INITWORD lib_Version=37,
  INITWORD lib_Revision=2, INITLONG lib_IdString
- init function: LibInit (hunk+0x72)

InitStruct byte-init format quirk: the data word stores the byte
value in its HIGH byte (`a0 08 09 00` writes 9 to ln_Type).
