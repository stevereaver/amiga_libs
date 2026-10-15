---
type: Structure
title: Layout
description: 0x40-byte MakeLibrary base and the single-hunk region map.
timestamp: 2026-10-15T16:40:00Z
---

# Library base (MakeLibrary, dataSize = 0x40)

```c
struct MDB45Base
{
    struct Library   mdb_Lib;       /* 0x00 .. 0x21 (neg=0x60,pos=0x40) */
    UBYTE            mdb_AttnFPU;   /* 0x22 = AttnFlags & 0x10 (68881/882) */
    UBYTE            mdb_pad23;     /* 0x23                              */
    ULONG            mdb_pad24;     /* 0x24 unused                       */
    struct ExecBase *mdb_SysBase;   /* 0x28 = a6 saved by init           */
    ULONG            mdb_pad2c[2];  /* 0x2c .. 0x33 unused               */
    APTR             mdb_OpenHook;  /* 0x34 code ptr called by Open       */
    APTR             mdb_CloseHook; /* 0x38 code ptr called by Close      */
    APTR             mdb_FPSPBase;  /* 0x3c fpsp.resource base or NULL    */
};                                  /* 0x40                              */
```

- mdb_OpenHook/mdb_CloseHook default to the `clr.l d0;rts` stub
  @code+0x68.  When AttnFlags bit4 is set, OpenHook is replaced by
  code+0xdbc: `move.l #$90,d0; fmove.l d0,fpcr; clr.l d0; rts`
  (FPCR = double precision + round-to-zero).
- mdb_AttnFPU (+0x22) is written by init but never read inside the
  library — vestigial (probably consumed by the companion
  mathieeedoubtrans build).
- InitStruct datatab @0xf6 fills: ln_Type=9, ln_Name->0x1e,
  lib_Revision=3, lib_Version=45, lib_Flags=6
  (LIBF_CHANGED|LIBF_SUMUSED), lib_OpenCnt=0.

# Hunk map (single CODE hunk, 0xdcc bytes)

| range | contents |
|-------|----------|
| 0x000 | entry `moveq #-1,d0; rts` |
| 0x004 | RomTag (COLDSTART, v45) |
| 0x01e | "mathieeedoubbas.library" |
| 0x036 | "$VER: ... 45.3 (23.11.2000)\r\n" |
| 0x068 | hook stub `clr.l d0; rts` |
| 0x06c | "fpsp.resource" |
| 0x07a | initfn |
| 0x0f2 | reserved -24 `moveq #0,d0; rts` |
| 0x0f6 | InitStruct datatab |
| 0x112 | Expunge / 0x14c Open / 0x168 Close |
| 0x17e | seglist cell (relocated) |
| 0x184/0x1a8/0x1cc | functab B / C / D (word-offset) |
| 0x1f0 | Ceil; 0x206-0x21d helpers |
| 0x21e-0x55f | software Floor + helpers |
| 0x31c/0x324 | Abs / Neg |
| 0x32c-0x605 | software Div, Cmp @0x560 |
| 0x606-0x897 | software Mul + shared helpers |
| 0x898 | Tst |
| 0x8b8/0x8c4 | software Sub -> Add |
| 0xb9c/0xbdc | software Flt / Fix |
| 0xca4-0xdb9 | FPU Flt/Fix/Floor-881/Floor-fpsp/Add/Sub/Mul/Div |
| 0xdbc | open hook (FPCR init) |
| 0xdca | pad; rt_EndSkip = 0xdcc |

RELOC32 (hunk tail): one group, hunk 0, offsets
`fc 7c 0a 1a 06 12 16` (non-sorted), then HUNK_END.
