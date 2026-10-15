---
type: Structure
title: XpkSubBase
description: 0xaa-byte base embedding both descriptor blocks.
---

# XpkSubBase — InitTable dataSize 0xaa

```c
struct XpkSubBase
{
    struct Library xsb_Lib;     /* 0x00                       */
    UWORD          xsb_Pad0;    /* 0x22                       */
    BPTR           xsb_SegList; /* 0x24 -- written by LibInit */
    struct XpkInfo xsb_Info;    /* 0x28 -- 88 bytes           */
    struct XpkMode xsb_Mode;    /* 0x80 -- 42 bytes           */
};                              /* = 0xaa                     */
```

Unlike xpkFRLE (dataSize 0x26, static descriptors), the
CBR0 base carries both descriptor blocks and LibInit
fills them field-by-field at runtime; XpksPackerInfo
returns base+0x28.
