---
type: Structures
title: launcher.library 41.9 layout
---

# Layout (datasize 0x64 = 34B LN/lib header + 66B private)

- +0x00 (0)   LN + Library header: ln_Type=NT_LIBRARY(9) @+8,
  ln_Name @+0xa, lib_Flags=6 @+0xe, lib_NegSize=0x1e/+0x10,
  lib_PosSize=0x86/+0x12, lib_Version=41/+0x14,
  lib_Revision=9/+0x16, lib_IdString @+0x18,
  lib_OpenCnt (word) @+0x20
- +0x22 (34)  SignalSemaphore (46B) — InitSemaphore'd at init,
  Obtain/Release around open/close state
- +0x50 (80)  seglist (set by initfn from a0)
- +0x54 (84)  SysBase (exec)
- +0x58 (88)  DOSBase (dos.library >= 37)
- +0x5c (92)  launcher server Process* (0 = not running)
- +0x60 (96)  server MsgPort* (created by server via exec -666)

# DATA hunk (h1, 72B)

- +0x00 'CON:0/25/640/150/\0' — console window spec (mode part 1)
- +0x12 '/AUTO/WAIT\0'        — console window spec (mode part 2)
- +0x1e functab: 5 absolute longs (h0+0xa5e/0xbda/0xb6e/0xc26/0x4b6)
  + ffffffff — only WORD-aligned
- +0x38 InitTable: datasize 0x64, functab -> h1+0x1e, datatab NULL,
  initfn -> h0+0x9f2

# CODE hunk data pockets

- h0+0x04..0x1d Resident (rt_Init reloc -> h1)
- h0+0x1e..0x4f name + idstring (CRLF-terminated)
- h0+0x2f0..0x31d: {0x433a0000?? 'C:\0\0' + 'icon.library\0\0' +
  'CLI\0' + '"\0' + pad + 'TOOLPRI\0' + 'dos.library\0'} —
  referenced by lea %pc@(...) in server-task + launch code
