# cxb.library — structures

## CxbBase (dataSize 0x430)

| off  | name            | notes                              |
|------|-----------------|------------------------------------|
| 0x00 | Library node    | OpenCnt @ 0x20, std fields         |
| 0x22 | custom flags    | bit3 = delayed-expunge (see defect)|
| 0x24 | SysBase         | stored by INITFUNCTION             |
| 0x28 | --              |                                    |
| 0x2c | seglist         | the REAL seglist (not @0x22)       |
| 0x30 | ctx slots[128]  | {task,ctx} pairs, task&0x380 idx   |

## Ctx (per-opener, 0x638 bytes via AllocMem)

Accessed as `a4 = ctx + 0x40`; header fields at negative a4
offsets.  The C `struct Ctx` places them so the byte offsets
match the original:

| a4 off | ctx off | field                       |
|--------|---------|-----------------------------|
| -64    | 0x00    | mem (the 0x638 block)       |
| -60    | 0x04    | pad                         |
| -56    | 0x08    | pad                         |
| -52    | 0x0c    | graphics.library base       |
| -48    | 0x10    | intuition.library base      |
| -44    | 0x14    | dos.library base            |
| -40    | 0x18    | SysBase                     |
| -36..-8| 0x1c..  | pad                         |
|  -4    | 0x3c    | saved caller sp             |
| a4+    | 0x40+   | fib / requester-text buffer |

## Static EasyStruct (cxbRequest)

es_StructSize=20, es_Level=0, es_Flags=0,
es_Title="cxb", es_TextFormat="cxb library request",
es_GadgetFormat="(C) 1998 by Captain Crossbones".
Called via `EasyRequestArgs(window=NULL, es, idcmp=0, args=0)`
on the *context's* intuition base.
