---
type: Structure
title: InitTable
description: AUTOINIT tables and InitStruct stream.
---

# InitTable / InitStruct

RomTag: RTF_AUTOINIT, RT_VERSION 0, NT_LIBRARY, pri 0,
RT_ENDSKIP at hunk end.

InitTable (hunk+0xba): dataSize 0xfc, abs-longword
functab (10 + -1), datatab at hunk+0xf6, initFunc at
hunk+0x184.

InitStruct stream beyond the standard fields also
writes (order as shipped):

```
8082 00000064   xm_Upto(0x82)        = 100
809e 42797465   xm_Desc(0x9e)        = 'Byte'
80a2 4d6f6465   xm_Desc(0xa2)        = 'Mode'
9026 0001       xi_XpkInfoVersion(0x26) = 1
9028 0000       xi_LibVersion(0x28)    = 0
902a 0001       xi_MasterVersion(0x2a) = 1
902c 0000       xi_ModesVersion(0x2c)  = 0
802e <reloc>    xi_Name     = "DLTA"
8032 <reloc>    xi_LongName = "DELTA v0.1"
8036 <reloc>    xi_Description
803a 444c5441   xi_ID       = 'DLTA'
803e 00002000   xi_Flags    = 0x2000
8042 00010000   xi_MaxPkInChunk = 0x10000
8046 00000001   xi_MinPkInChunk = 1
804a 00010000   xi_DefPkInChunk = 0x10000
804e <reloc>    xi_PackMsg  = "Enciphering"
8052 <reloc>    xi_UnpackMsg= "Deciphering"
8056 <reloc>    xi_PackedMsg= "Enciphered"
805a <reloc>    xi_UnpackedMsg = "Deciphered"
905e 0064       xi_DefMode  = 100
0000            terminator
```

Only the six string fields carry hunk relocs — scalar
writes are literals.  The reconstructed datatab.s emits
this stream byte-identically.
