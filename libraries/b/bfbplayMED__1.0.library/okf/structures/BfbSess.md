# BfbSess (80 bytes, MEMF_PUBLIC — NOT cleared)

All LONGs sit at offset%4==2 — unaligned, 68020+ only.

| off | field |
|-----|-------|
| +0  | UBYTE type = 4 |
| +1  | UBYTE playing |
| +2  | APTR modbuf |
| +10 | ULONG modlen |
| +20 | UWORD maxvol — never initialized; SetVolume clamps to it |
| +21 | UBYTE modhdr51 = modbuf[51] |
| +26 | ULONG = 120 |
| +46 | UBYTE stopped |
