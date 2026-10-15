---
file: layout
---
# dg8svx 2.1 layout

File 5556B (0x15b4). Header 0x3f3, no names, 2 hunks,
table [0x51a, 0xf].

- h0 CODE tag @0x1c, body @0x24 (0x51a longs = 5224B).
  Tail: RELOC32 @0x148c — one block, 49 slots in scrambled
  order (24 ->h0: resident+InitTable+ftab+dtab string ptrs;
  25 ->h1: code operands addressing the DATA hunk), END
  @0x1568.
- h1 DATA tag @0x156c, body @0x1574 (0xf longs = 60B).
  Tail: END only @0x15b0. EOF 0x15b4. No DEBUG/SYMBOL/
  HUNK_NAME records; no DREL.

## h0 body

- +0: `moveq #0,d0;rts` pre-resident stub.
- +4: Resident 4afc, match->+4, endskip->+0x27a, flags 0x80
  AUTOINIT, ver 2, type NT_LIBRARY, pri 0, name->+0x69,
  id->+0x78, init->+0x9e.
- +0x1e: strings dos.library / graphics.library /
  toolkit.library / dgaudio.library / dgiff.library /
  "dg8svx.library" / "dg8svx 2.1 (15.7.94) (c) Optonica Ltd".
- +0x9e: InitTable — dsize 0x26, ftab->+0xae, dtab->+0xe2,
  initfn->+0x102.
- +0xae: 12 abs-long vectors + 0xffffffff term @+0xde.
- +0xe2: InitData — a0/dd=2 byte-offset commands:
  byte 9 ->+0x0c (DEAD, see defects), long name->+0x0a,
  byte 6 ->+0x0e lib_Flags, word 2 ->+0x14 ver, word 1
  ->+0x16 rev, long idstr->+0x18, 0 term.
- +0x102: initfn `a1=d0; move.l a0,0x22(a1)` (seglist),
  `move.l a6,(h1+4)` (SysBase into DATA hunk), rts.
- +0x110 Open (lazy dep-open), +0x216 Close, +0x236 Expunge,
  +0x276 reserved stub, +0x27c/-36..-72 code, gcc-signed-div
  helper +0x13a4..0x1464.

## h1 body (DATA, 60B)

- +0x00 long: dos.library base (written by Open)
- +0x04 long: SysBase (written by initfn via ->h1 reloc;
  Open/Close/Expunge read SysBase from here, not $4)
- +0x08 gfx, +0x0c toolkit, +0x10 dgiff, +0x14 dgaudio
- +0x18 code stub `addq.l #1,(a1); moveq #0,d0; tst.l d0;
  rts` — tick/count callback passed to toolkit -228 by -60
- +0x20 12B tag defaults copied by -30: {w 1, w 1, l 0, l -1}
- +0x2c 16B Fibonacci-delta table de eb f3 f8 fb fd fe ff
  00 01 02 03 05 08 0d 15 (classic 8SVX fibDelta)
- ends +0x3c

## Lib base (dsize 0x26)

+0x14 ver=2, +0x16 rev=1, +0x18 idstr, +0x20 OpenCnt,
+0x22 seglist (initfn store / Expunge returns it),
+0x24 pad. ln_Type@+8 stays 0 (InitData defect).
