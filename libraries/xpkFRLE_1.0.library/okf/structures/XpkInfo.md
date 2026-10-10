---
type: Structure
title: XpkInfo
description: Packer descriptor chain returned by XpksPackerInfo.
---

# XpkInfo (hunk +0x30e, 88 bytes)

```c
xi_XpkInfoVersion = 1, xi_LibVersion = 1
xi_MasterVersion  = 2, xi_ModesVersion = 0
xi_Name        -> "FRLE"
xi_LongName    -> "Fast Run Length Encoder 1.0"
xi_Description -> "Cache-optimized RLE."
xi_ID          = 'FRLE'
xi_Flags       = 9              // XPKIF_PK_CHUNK | XPKIF_UP_CHUNK
xi_MaxPkInChunk = 0x20000       // 131072
xi_MinPkInChunk = 0x10          // 16
xi_DefPkInChunk = 0x8000        // 32768
xi_PackMsg     -> "Packing"   xi_UnpackMsg   -> "Unpacking"
xi_PackedMsg   -> "Packed"    xi_UnpackedMsg -> "Unpacked"
xi_DefMode     = 0x10
xi_ModeDesc    -> XpkMode
```

# XpkMode (hunk +0x366, 42 bytes)

```c
xm_Next = 0, xm_Upto = 100, xm_Flags = 1 (XPKMF_A3000SPEED)
xm_PackMemory = 0, xm_UnpackMemory = 0
xm_PackSpeed = 800, xm_UnpackSpeed = 1480
xm_Ratio = 2, xm_ChunkSize = 0
xm_Description = "ByteRun"
```
