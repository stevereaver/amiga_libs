# xpkFAST 1.10 structures

## Library base

dataSize `0x22` — a **bare `struct Library`** with no private
fields (1.06 used 0x4a: +34 execbase, +38 seglist).  Private
state is gone:

- exec is fetched per use via `moveal 4:w,a6`.
- the seglist is stashed at **code+0x7a** — a dead longword in
  the consumed datatab tail, written by `movel a0,segslot:l`
  whose operand has a hunk reloc (reloc offset 0x84 lands on the
  operand).  LibExpunge reads it back PC-relative.

## InitTable (code+0x1e)

`{dataSize 0x22, functab 0x2e, datatab 0x5a, initfunc 0x7e}`.
The functab starts right after the table; datatab after the
terminator; the dead cells between datatab's last entry and
initfunc supply the segslot.

## datatab (InitStruct ops)

```
8008 09    InitByte  +8  9    ln_Type NT_LIBRARY
8014 01    InitByte +20  1    lib_Version
8016 0a    InitByte +22 10    lib_Revision
a00a ...   ptr       +10      ln_Name -> name
a018 ...   ptr       +24      lib_IdString -> idstr
```

Note `8008`: ln_Type is written at the **correct** offset +8 —
1.06's `800c` wrote it at +12 (inside ln_Name) where the name
pointer then overwrote it, leaving ln_Type garbage.  Fixed here;
LIBF_CHANGED is not written (flags byte stays 6 from `move.w`).

## Dead cells / segslot (code+0x70..0x7d)

`datatab` ends with a dummy `8000 00` + three spare cells;
`dc.l -1` terminator at +0x76, one dead `dc.l 0` at +0x7a =
segslot, initfunc at +0x7e.  Byte-identical to the original's
layout (verified: initfunc@0x7e, reloc@0x84 hits the segslot
store operand).

## RomTag quirk (relocated entry stub, unrelocated MatchTag)

Reloc list covers offsets {0, 22, 30, 34, 38, 42, 50, 54, 58,
62, 66, 70, 74, 78, 96, 132, 244, 1680..1720}:

- offset **0** — the dead `moveq #-1,d0` entry stub gets its
  immediate `0xffffffff` patched with the hunk base -> d0 holds
  a code address instead of -1.  Dead code (never executed).
- offset **6** (`rt_MatchTag`) is ABSENT -> MatchTag keeps the
  literal file offset 4 at runtime; exec matches libraries by
  `rt_Name` string compare + `rt_Version`, so it's never read.
  Same defect as 1.06; 1.2 relocates 0x6 properly.

## XpkSubParams (xsp) — unchanged from 1.06

Sub[0]=workmem ptr @0x34, Sub[1]=alloc size @0x38; Mode @0x1c
(<=80 speedy / >80 crawling).  See 1.06's layout.md.

## Workmem

- speedy 0x10000: u32[16384] hash, prefilled `in_end`.
- crawling 0x44000: 64K hash heads reachable at work+0..0x40000
  via the biased-index wrap, chain u32[4096] at work+0x40000.

## Descriptor (code+0x67a)

```
0x8009           flags
'FAST'           id
'FAST alias WOOP or LZRW++',0        longname (no version!)
'xpkFAST.library',0                  libname
0, 0x7fffffff                        reserved / max chunk
'Packer can be used freely, but may only be
 distributed with the XPK master.',0  copyright
'Christian von Roques',0             author
0x10000        0x00000032            def chunk, def mode
0x67e..      8 x longs             tieing/untieing/compressed/
                                   decompressed strings
mode rec: 0x1ac,79,0x41f,0x147,0x10000,"speedy"
mode rec: 0x046,100,0x448,0x189,0x44000,"crawling"
```
