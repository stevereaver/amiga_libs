---
type: Structure
title: xpkILZR 1.2 XpkSubParams
---

# XpkSubParams

```
+0x00  xsp_InBuf       input
+0x04  xsp_InLen       input length
+0x08  xsp_OutBuf      output
+0x0c  xsp_OutBufLen   out capacity; decoder REWRITES it
                       with the declared length (header u16)
+0x10  xsp_OutLen      pack writes bytes produced here
+0x14  xsp_Flags
+0x18  xsp_Number
+0x1c  xsp_Mode        read nowhere by this build
+0x20  xsp_Password
+0x24  xsp_LibVersion
+0x26  pad
+0x28  xsp_Arg[3]
+0x34  xsp_Sub[0]      chain table (0x8024 via suballoc)
+0x38  xsp_Sub[1]      head table (0x10000 via suballoc)
+0x3c  xsp_Sub[2..3]   unused
```

- pack bound = `OutBuf + OutBufLen` (byte-level, -17)
- unpack bound = `OutBufLen` vs declared u16 (-10 once)
- Sub[0] NULL → both blocks (re)allocated next PackChunk
