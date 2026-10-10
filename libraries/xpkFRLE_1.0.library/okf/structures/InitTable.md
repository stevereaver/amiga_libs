---
type: Structure
title: InitTable
description: AUTOINIT vector — dataSize 0x26, word-offset functab.
---

# InitTable (hunk +0x56)

```c
dataSize  = 0x26
funcTable -> hunk+0x66   // -1, ten .word offsets (base = marker), -1
dataTable -> hunk+0x7e   // InitStruct stream
initFunc  -> hunk+0x9e   // stores a0 seglist at base+0x22
```

Functab offsets are word displacements from the marker word at
hunk+0x66 (e.g. 0x44 -> +0xaa Open, 0xdc -> +0x242 UnpackChunk).

InitStruct stream: NT_LIBRARY, flags 0x06
(LIBF_SUMUSED|LIBF_CHANGED), version 1, **revision 0**,
idstring `xpkFRLE.library 1.0 (31-Jan-93)\r\n`.
