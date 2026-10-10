# BfbBase (dataSize 0xb2 = 178)

| off | field |
|-----|-------|
| +0  | struct Library (34B; OpenCnt +32) |
| +34 | UBYTE flags — bit3 delayed-expunge |
| +36 | ExecBase * |
| +40 | dos.library base |
| +44 | seglist |
| +48 | medplayer.library base (opened by InitModule, cleared by EndModule) |
| +156| UWORD mpinit — medplayer -30 init done |
