# structures

- [workmem](workmem.md) -- 0x3800 work area: trie, node arena,
  fast table, length/code/histogram tables

Public ABI (shared with all Froehling XPK sublibraries):

- `XpkSubParams` (a0): xsp_InBuf +0, xsp_InLen +4, xsp_OutBuf +8,
  xsp_OutBufLen +12, xsp_OutLen +16, ..., xsp_Sub[0] +52 (workmem).
- `XpkInfo` descriptor: static, returned by -30.  ID 'SMPL',
  PackMemory 0x3710 / UnpackMemory 0x1000, DefMode 50, single
  XpkMode "normal".
- `XpkMode`: xm_Upto 100, xm_Flags 1, xm_PackMemory 0x3710,
  xm_UnpackMemory 0x1000, xm_PackSpeed 0x97, xm_UnpackSpeed 0x162,
  xm_Ratio 67, xm_ChunkSize 63, name "normal".
