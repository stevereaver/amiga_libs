---
type: Structure
title: XpkSubParams
description: XPK chunk packer argument block (as consumed by this binary).
---

# XpkSubParams

```c
struct XpkSubParams {
    APTR  xsp_InBuf;        // 0x00
    ULONG xsp_InLen;        // 0x04
    APTR  xsp_OutBuf;       // 0x08
    ULONG xsp_OutBufLen;    // 0x0c  pack bound = OutBuf + OutBufLen
    ULONG xsp_OutLen;       // 0x10  written by pack AND unpack
    ULONG xsp_Flags;        // 0x14
    ULONG xsp_Number;       // 0x18
    ULONG xsp_Mode;         // 0x1c
    STRPTR xsp_Password;    // 0x20
    UWORD xsp_LibVersion;   // 0x24
    UWORD xsp_Pad;          // 0x26
    ULONG xsp_Arg[3];       // 0x28
    ULONG xsp_Sub[4];       // 0x34
};
```

Pack reads InBuf/InLen/OutBuf/OutBufLen and writes OutLen.
Unpack reads InBuf/InLen/OutBuf and writes OutLen; OutBufLen is
ignored by both directions for bounds purposes (pack uses it as
the output limit, unpack ignores it entirely).
