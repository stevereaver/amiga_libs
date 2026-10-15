---
file: layout
---
# realtime 37.3 layout

File 6132B. Header @0x00: tablesize 2, hunk sizes [0x4ae, 0x19] longs.

## hunk0 — CODE @0x1c

decl 0x4ae longs, body 4792B @0x24..0x12db.
Tails: RELOC32 @0x12dc (24 slots ->h0 + 14 slots ->h1),
HUNK_SYMBOL @0x138c (40 symbols), HUNK_END @0x1768.

| off | contents |
|-----|----------|
| 0x00 | FalseStart: `moveq #-1,d0 / rts` |
| 0x04 | Resident: flags 0x80 AUTOINIT, ver 37, type 9, pri 0; endskip->+0x12b8, name->+0x1e, idstr->+0x2f, init->+0x4a |
| 0x1e | "realtime.library"\0 |
| 0x2f | "realtime 37.3 (10.12.92)\r\n"\0 |
| 0x4a | InitTable: dsize 0xb0, functab->+0x7c, datatab->+0x5a, initfn->+0xb8 |
| 0x5a | InitData stream (see below), ends @+0x76 (byte 0) |
| 0x7c | FuncTable: 14 absolute longs + `ffffffff` terminator |
| 0xb8 | InitLib -> InitCEnv(zero 21 data longs) -> _InitLibC |
| 0x150 | _InitLibC: OpenResource("misc.resource"), OpenLibrary("dos.library",33), OpenLibrary("utility.library",33), NewList(lib+0xa0), InitSemaphore(lib+0x44) + InitSemaphore(lib+0x72), _InitTimer |
| 0x1c6/0x1d4/0x1e0 | "misc.resource" / "dos.library" / "utility.library" |
| 0x2e4/0x2f2 | "ciaa.resource" / "ciab.resource" |
| 0xfea | "graphics.library" (only opened by _EClockFreq when exec<36) |
| 0x4e4 | _CIAHandler (exec Cause -180) / 0x4f8 _TickHandler (exec Signal -324) |
| 0x1168/0x117c | _AddICRVector / _RemICRVector thunks -> resource -6 / -12 |
| rest | _LIBLockRealTime.._LIBGetPlayerAttrsA bodies, _next_tag/_find_tag/_get_tagdata (inlined utility fns), SAS/C runtime __CXM33/__CXD22/__CXD33/__CXM22 |

## hunk1 — DATA @0x176c

chunk size field = 4 longs -> physical body 16B @0x1774
(`80000044 00000000 00000000 00000000`) BUT hunk-table alloc is
0x19 longs (100B): +0x10..+0x63 is load-time-undefined space used
as A4-relative globals, zeroed at init by InitCEnv (21 longs from
+0x10).  Symbols: _RealTimeBase +0x10, _DOSBase +0x14,
_UtilityBase +0x18, _MiscBase +0x1c, _TimerData +0x20.
Tail: HUNK_SYMBOL (5) @0x1784, HUNK_END @0x17f0.

## InitData stream @h0+0x5a

`a0 08 09 00` -> INITBYTE(8, 9)   ln_Type = NT_LIBRARY
`80 0a <l>`    -> INITLONG(0xa)  ln_Name -> +0x1e (relocated ->h0)
`a0 0e 06 00` -> INITBYTE(0xe,6) lib_Flags = LIBF_SUMUSED|LIBF_CHANGED
`90 14 <w>`    -> INITWORD(0x14) lib_Version = 37
`90 16 <w>`    -> INITWORD(0x16) lib_Revision = 3
`80 18 <l>`    -> INITLONG(0x18) lib_IdString -> +0x2f (relocated ->h0)
`00`           -> end

## library-private area (InitTable dsize 0xb0)

+0x30 SysBase, +0x34 DOSBase, +0x38 UtilityBase, +0x3c MiscBase,
+0x40 seglist, +0x44 semaphore A, +0x72 semaphore B (two semaphores,
stride 46 = 0x2e for LockRealTime slot n), +0xa0 conductor list
(NewList'd), +0xac/+0xad flags, +0xae lock bitmask word.

## reloc notes

RELOC32->h0 (24): resident ptrs +6/+0xa/+0x12/+0x16/+0x1a, InitTable
+0x4e/+0x52/+0x56, InitData-embedded ptrs +0x60/+0x72, functab slots
+0x7c..+0xb0.  RELOC32->h1 (14): the per-function `lea EndSkip,a4`
sites +0x158/+0x1f6/+0x500/+0x5d4/+0x62a/+0x680/+0x974/+0x9e0/
+0xb3c/+0xb68/+0xb92/+0xbb8/+0xbfa/+0x222 — all stored as small
h1-relative offsets (EndSkip itself = h1+0).
