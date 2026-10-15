# SlzBase (dataSize 0x26 = 38)

| off | field |
|-----|-------|
| 0x00 | struct Library (34 bytes) |
| 0x22 | ULONG pad |
| 0x26 | BPTR seglist -- stored by LibInit ONE LONG past the 38-byte
  PosSize; only legal because AllocMem rounds 38 up to 40 bytes |
