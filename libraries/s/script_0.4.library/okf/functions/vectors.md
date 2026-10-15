# script.library 0.4 — vector map

AUTOINIT.  `rt_Init -> DATA hunk +4` = InitTable
`{ dsize=0x50, functab -> hunk2+0, datatab=0, initfn -> h0+0x20 }`.

Function table (hunk2, long-absolute, `-1` terminated):

| vec | offset | semantics (reconstructed)                                    |
|-----|--------|--------------------------------------------------------------|
| -6  | 0x0c4  | Open: `opencnt++`, clear DELEXP, ret lib                       |
| -12 | 0x0d6  | Close: `opencnt--`; at 0 with DELEXP -> Expunge, ret seglist   |
| -18 | 0x100  | Expunge: set DELEXP; if open defer; else Remove + FreeMem      |
| -24 | 0x000  | null vector -> `moveq#0,rts` stub at hunk0+0                   |
| -30 | 0x18e  | (a0=ctx, a1=name, a2=str) rexxsyslib round-trip; status d0. a2 is a live register arg (strlen'd). On probe fail -> callback/store fallback via ctx+124 |
| -36 | 0x206  | (a0=ctx, a1=name, a2=out) same protocol; writes *a2 on the -652 path; `*a2=0` first |
| -42 | 0x25e  | () -> ctx: CreatePool(1,1024,1024) + AllocPooled(24) + NewList(ctx+8); ctx+20 = pool |
| -48 | 0x2e6  | (a0=ctx) DeletePool(ctx+20); return value = residual d0        |
| -54 | 0x328  | (a0=ctx, a1=ptr) store ptr at ctx+124 (OOB on the 24B ctx!)    |
| -60 | 0x342  | (a0=ctx) -> d0 = ctx+124                                     |
| -66 | 0x35c  | (a0=ctx, a1=name, a2=data) find-or-add pooled node; ret 0 or 3 |
| -72 | 0x38e  | (a0=ctx, a1=name, a2=out) find node; `*a2` = node->data, ret 0 |

## Internal helpers (hunk0)

| offset | role |
|--------|------|
| 0x158  | set lib+48 obj +24=SysBase, +28=libbase                     |
| 0x17a  | empty helper (sets a4=lib+48 only)                            |
| 0x3b8  | list-walk + free — **dead code, no caller**                   |
| 0x3e8  | free node: Remove + FreePooled(name/data/node)                |
| 0x472  | find-or-add named node (pooled strings, AddHead)              |
| 0x652  | find node by name -> node+12 (data)                          |
| 0x6a4  | rexxsyslib probe: OpenLibrary/Close; if arg+24==rexxbase && arg+20 -> IsRexxMsg(arg) (-168) |
| 0x6a8  | register-arg entry of the probe                               |
| 0x6e6  | arg-shuffle wrapper -> 0x6fe; writes a1 to *out on fail       |
| 0x6fe  | rexx round-trip v1: rxx -108 -> 0x7de -> rxx -72              |
| 0x744  | rexx round-trip v2 (with len): stash/restore msg+252 via 0x896/0x8b6; rxx -108 -> 0x7de -> rxx -66 -> 0x848 -> rxx -84 |
| 0x7de  | node alloc + '.' split + stored-vs-computed len verify        |
| 0x848  | 12B-str node alloc via rxx -114/-270                          |
| 0x87c  | conditional node free via rxx -120 (kept if flag bit0 set)    |
| 0x896  | stash (cont-ptr, save-area) at msg+252; save old pair         |
| 0x8b6  | restore msg+252 pair                                          |
| 0x8e0  | stack-arg NewList                                             |

## Private rexxsyslib.library vectors invoked

-168 IsRexxMsg, -108, -288 (ret a0=ptr,d0=len), -114 (alloc
d0-size -> a0), -270 (copy a1->a0), -102 (strlen a0 -> d1), -120 (free
a1,d0), -72, -66, -84.  None are in the public NDK list.

## Exec vectors used

OpenLibrary -552, CloseLibrary -414, Remove -252, FreeMem -210,
CreatePool -696, DeletePool -702, AllocPooled -708, FreePooled -714,
CopyMem -624, AddHead -240.
