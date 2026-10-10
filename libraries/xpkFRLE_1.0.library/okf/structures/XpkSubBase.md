---
type: Structure
title: XpkSubBase
description: Library node + saved seglist (dataSize 0x26).
---

# XpkSubBase

```c
struct XpkSubBase {          // InitTable dataSize 0x26
    struct Library lib;      // 0x00 (34 bytes)
    BPTR  seglist;           // 0x22, written by LibInit
};
```
