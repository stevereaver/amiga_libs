# cxb.library 37.1 — reconstruction log

## 2026-10-28 — reverse engineering + reconstruction

### Binary inspection

- 1388-byte single CODE hunk, SAS/C build.
- RomTag `4afc` at 0x24, RTF_AUTOINIT (0x80), ver 37,
  NT_LIBRARY, RT_INIT -> InitTable at hunk-off 0x1e.
- InitTable: `dataSize 0x430`, FUNCTABLE @ 0x390,
  DATATABLE @ 0x2e, INITFUNCTION @ 0x4e.
- FUNCTABLE: 8 LONG-address vectors + two `0xffff`
  terminators.
- strings: "cxb.library", "cxb.library 37.1 (20.01.98)",
  "dos.library", "intuition.library", "graphics.library",
  "(C) 1998 by Captain Crossbones of FR-SoftWorks".

### Framework decode

- INITFUNCTION: `MOVE.L A6,36(A5)` (SysBase),
  `MOVE.L A0,44(A5)` (seglist), then `MOVEQ #127; CLR.L (A0)+
  ; DBF` — clears **128 longs (512 bytes)** at base+48.
- Open: opencnt@32++, `BCLR #3,34(A6)` (custom flag byte),
  Forbid, scan 16 slots at `base+48+(ThisTask&0x380)` for an
  empty one (8-byte stride), Permit, then allocate a 0x638
  context and open the three libraries into it.
- Close: scan slots for `ThisTask`, free its context,
  opencnt--, delayed-expunge if the flag is set.
- Expunge: if open set flag@34 bit3 and return 0, else
  Remove+FreeMem and return seglist@44.
- DATATABLE InitStruct sets ln_Type=9, ln_Name=libname,
  lib_Flags=6, Version=37, Revision=1, and — quirk —
  lib_IdString = **libname** (not the "$VER" string).

### Public functions

- `-30` cxbFileInfo: Lock(ACCESS_READ) + Examine + UnLock,
  returns 0/-1 through the context's dos base.
- `-36` cxbMult: `d0*d1` via a 32-bit multiply helper.
- `-42` cxbMult209: `d0*0xd1` (a*209).
- `-48` cxbRequest: EasyRequestArgs on a static EasyStruct
  whose gadget format is the "(C) 1998 …" attribution string.

### Reconstruction notes

- `cxb_lib.s` carries the exact InitStruct datatab, the
  INITFUNCTION, the 8-long FUNCTABLE, the static EasyStruct
  and a stack-arg `__mulsi3` for the `a*b` multiply.
- `cxb.c` implements the framework + functions; the per-
  context `struct Ctx` reproduces the a4-relative field
  offsets exactly (gfx@12/intu@16/dos@20/sys@24).
- Built `cxb.library` = 1240 bytes, single CODE hunk, same
  datatab and vector layout (different code addresses).

### Verification

- m68k cross build clean (only expected `SYSBASE @4`
  array-bounds warnings).
- datatab bytes identical to the original.
- functab 8 vectors in the same order.
- generated Open matches the original sequence:
  `addq.w #1,32; andi.b #-9,34; jsr -132; andi.l #0x380
  (task); scan 16x8; jsr -138; allocmem 0x638; openlib x3`.
- `cxbMult209` compiles to `a + (13a<<4)` = `209a`.
- `cxbMult` routes through `__mulsi3` -> correct 32-bit
  product.

### Known shipped defects (see findings/)

- HALF-CLEARED CONTEXT TABLE: INIT clears only 512B of the
  1024-byte table, so tasks whose `ThisTask&0x380 >= 0x200`
  scan uninitialized slots.
- CUSTOM FLAG @ 34: the library repurposes
  `lib_SegList`'s byte slot for its DELEXP bit; tools that
  read `lib_SegList` at 0x22 will see the flag, not a BPTR.
- IdString quirk: `lib_IdString` points at "cxb.library",
  not the version string.
