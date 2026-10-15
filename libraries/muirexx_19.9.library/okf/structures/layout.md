---
file: layout
---
# muirexx 19.9 layout

File 5224B. Header 0x3f3, no names, tablesize 2, hunks 0..1,
sizes 0x4d0 / 0x5 longs.

- h0 CODE 0x4d0 longs = 0x1340B @file 0x24..0x1364. RELOC32:
  42->h0 (0x58..0x70 RomTag self ptrs, 0x78..0x1b8 table ptrs,
  0x380 lea functab in init, 0xe40..0xe70 functab slots, 0x11ea
  one code ref), 13->h1 (all `lea 0.l,a4` / `moveal (x).l` refs
  to BSS globals: 0x4f6 0x514 0x526 0x5a0 0x8ca 0x8e8 0xafc
  0xb24 0xb88 0xbe6 0xc36 0xcec 0xdac). END @0x1458.
- h1 BSS 0x5 longs = 20B, no body, END @0x1464 (EOF 0x1468).

## h0 CODE map

| off | content |
|-----|---------|
| 0x000 | `moveq #0,d0; rts` reserved stub (also vector -24 target) |
| 0x004 | "muirexx.library" (rt_name target) |
| 0x014 | "$VER: muirexx.library 19.9 (12.02.97) "(c)"1992-1997 Stefan Stuntz\r\n" |
| 0x056 | RomTag, 26B, endskip->0x70 |
| 0x070 | five 0x14B handler records {0,0,codeptr,0,0}: 0x604,0x636,0x666,0x78e,0x748 |
| 0x0d4 | seven 0x24B std-command records {name,templ,flag,hdlptr,0,0,0,0,0} |
| 0x1f4 | strings: dep names (dos/utility/intuition/muilowlevel.library), tag names (base/title/author/copyright/description/version/screen), help texts, cmd names (quit FORCE/S, hide, deactivate, show, activate, info ITEM/A, help FILE/A), "REXX", "_", "99: Port Closed!", "rexxsyslib.library", "rexx", ".LASTERROR" |
| 0x374 | init routine (rt_init target) + all code |
| 0x604-0x78e | builtin cmd handlers (quit/hide/show/info/help) |
| 0xe40 | functab: 13 abs-longs, -1 term @0xe74 |
| 0xe78..0x133f | internal helpers (rexxsyslib open/CreateRexxMsg, name utils) |

## RomTag @h0+0x56

4afc, matchtag->self (0x56), endskip->h0+0x70, **flags 0x00
(NOT AUTOINIT)**, ver 19, type 9 (NT_LIBRARY), pri 0,
name->h0+4, idstring->h0+0x1a (skips the "$VER: " prefix),
init->h0+0x374 direct code pointer.

## init routine @h0+0x374 (a0=seglist)

moveml d2/a2-a3/a5-a6; d2=a0(seglist); a5=*(4) exec;
MakeLibrary(ftab=h0+0xe40, initStruct=0, initFn=0, dSize=0x54,
segList=0) [exec -84]; on success fills node: lib+8 type=9,
lib+0xa name->h0+4, lib+0xe flags=6, lib+0x14 ver=19,
lib+0x16 rev=9, lib+0x18 id->h0+0x14 ("$VER:..." incl. prefix),
lib+0x22 seglist (private slot, 2B below std lib_SegList),
NewList(lib+0x26) [exec -558]; BSS+0=exec; AddLibrary(lib)
[exec -396]; returns lib. On MakeLibrary fail: FreeMem, ret 0.

## h1 BSS (20B) — globals via abs-long operands

- +0x00 SysBase (stuffed by init helper @h0+0x4ec)
- +0x04 DOSBase     (OpenLibrary "dos.library",36 on 1st Open)
- +0x08 UtilityBase ("utility.library",36)
- +0x0c IntuitionBase ("intuition.library",36)
- +0x10 MUIMasterBase slot ("muilowlevel.library",19)

## Library data area (dsize 0x54)

- +0x20 lib_OpenCnt (std) — inc/dec by Open/Close
- +0x22 seglist (private placement, not std +0x24)
- +0x26 list head (NewList'ed; used as Obtain/ReleaseSemaphore
  arg at exec -564/-570 — the node doubles as SignalSemaphore)
- lib+0xe bit3 = deferred-expunge flag
