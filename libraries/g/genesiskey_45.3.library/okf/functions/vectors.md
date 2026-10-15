# Vectors

Absolute-pointer function table (dc.l entries) at code+0x28c,
terminated by `-1`.  15 vectors plus reserved slot.

| LVO | Target | Function |
|-----|--------|----------|
| -6  | 0x16c | **LibOpen** — ObtainSemaphore(lib+36); OpenCnt++; Flags&=~DELEXP; on first open calls dep-opener; on failure closes deps, restores count, returns NULL; ReleaseSemaphore; returns lib/NULL |
| -12 | 0x224 | **LibClose** — ObtainSemaphore; if OpenCnt==1 close deps; OpenCnt--; ReleaseSemaphore; if OpenCnt==0 && DELEXP → expunge → returns seglist; else 0 |
| -18 | 0x1cc | **LibExpunge** — if OpenCnt==0: d2=BSS seglist, Remove(lib), FreeMem(lib-NegSize, Neg+Pos), return seglist; else Flags\|=8 (DELEXP), return 0 |
| -24 | 0x282 | reserved — returns 0 |
| -30 | 0x3ae | empty stub |
| -36 | 0x3b6 | empty stub |
| -42 | 0x3be | empty stub |
| -48 | 0x3c6 | empty stub |
| -54 | 0x346 | **Socket probe** — OpenLibrary("genesis.library",3); NULL→0; else CloseLibrary it and `return OpenLibrary("bsdsocket.library",4)` |
| -60 | 0x3ce | empty stub |
| -66 | 0x392 | returns **0x20** — data-hunk offset of serial string `"454545"` |
| -72 | 0x3d6 | empty stub |
| -78 | 0x3a0 | returns **0x120** — data-hunk offset of `"AmigaOS 3.9"` |
| -84 | 0x3e6 | empty stub (**crossed**: uses the later of the two tail stubs) |
| -90 | 0x3de | empty stub (**crossed**: uses the earlier stub) |

## Internal functions (not vectored)

| Addr | Role |
|------|------|
| 0x00 | Entry stub: `link/unlk` around `moveq #30,d0` — running the file as a program exits with RETURN_FAIL=30 |
| 0x38 | `open_deps` — OpenLibrary dos/intuition/utility v40 → data+4/+8/+0xc; returns 1 iff all three opened |
| 0xb2 | `close_deps` — CloseLibrary data+0xc/+8/+4 (reverse order) clearing each slot |
| 0x114 | **LibInit** (InitTable[3]; d0=lib, a0=seglist, a6=exec) — stores exec→data+0; `btst #1, exec+297` (AttnFlags bit1 = **AFF_68020**): set → seglist→BSS+0, lib_Revision=3, InitSemaphore(lib+36), return lib; clear → FreeMem(lib-NegSize, Neg+Pos), return NULL |

## Exec LVOs used

- -552 OpenLibrary, -414 CloseLibrary, -210 FreeMem, -252 Remove,
  -558 InitSemaphore, -564 ObtainSemaphore, -570 ReleaseSemaphore.
