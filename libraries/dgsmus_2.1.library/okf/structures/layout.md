---
file: layout
---
# dgsmus 2.1 layout

File 4940B. Hunk table: 3 hunks, sizes 0x39b / 0x9a /
0x3e|MEMF_CHIP (flag bit 30 set in both the table entry and
the record tag 0x400003ea).

- hunk0 CODE 0x20..0xe94: body 3692B @0x28, declared ==
  physical. Tail: single RELOC32 record (31 slots ->hunk0,
  39 slots ->hunk1, 1 slot ->hunk2 at code+0x62e), END.
- hunk1 DATA 0xfd4..0x1244: body 616B @0xfdc, END.
- hunk2 DATA|CHIP 0x1248..0x1348: body 248B @0x1250 —
  62 longwords alternating 0x7f7f7f7f/0x80808080 (a 124
  byte-square-wave Paula'sample), END.

Resident @h0+4: matchword 4afc, matchtag ->h0+4, endskip
h0+0x2b8, flags 0x80 (RTF_COLDSTART), ver 2, type 9
(NT_LIBRARY), pri 0; name h0+0x78 "dgsmus.library", id
h0+0x87 "dgsmus 2.1 24-Aug-93 (c) Optonica Ltd", init
h0+0xae.

Sublibrary name strings embedded at h0+0x40..0x9d:
dos.library @0x40, graphics.library @0x4e, toolkit.library
@0x5d, dgaudio.library @0x6d, dg8svx.library @0x7d,
dgiff.library @0x8e (+ dgsmus.library @0x98? -> name slot).

InitTable @h0+0xae: dsize 0x26 (34B Library + 4B seglist
@+0x22), functab ->h0+0xbe (21 abs longs, -1 term),
datatab ->h0+0x116 (word-format InitStruct), initfn
->h0+0x136 (stores seglist->lib+0x22, SysBase->hunk1+0,
returns libbase).

InitStruct datatab (h0+0x116..0x135): $a00c -> dead byte
9 @lib+0x0c (inside ln_Name, overwritten by next cmd);
$800a -> ln_Name=libname; $a00e -> lib_Flags=6
(SUMUSED|CHANGED); $9014 -> lib_Version=2; $9016 ->
lib_Revision=1; $8018 -> lib_IdString; $0000 end.
ln_Type is never set by the table (MakeLibrary default).

DATA hunk1 globals map (A4 base in all LIBFUNCs):
+0x00 exec base (stored by initfn); +0x04 dos.library;
+0x08 graphics.library; +0x0c toolkit.library; +0x10
dgiff.library; +0x14 dg8svx.library; +0x18 dgaudio.library;
+0x1c,+0x20 = $ffffffff sentinels; +0x24..+0x6b = 18 longs
of packed word pairs (period table, indexed by word via
LEA 36(A4) in LIBFUNC_5); +0x6c..+0xeb = 32 longs of
word pairs (second table, indexed via LEA 108(A4) in
LIBFUNC_7/8); +0xec..+0x267 zero-init runtime area:
+0xec "playing" handle (236(A4)); +0xf0/+0xf4 fixed-point
tempo results (240/244(A4)); +0xf8 per-channel ctx ptr
array (248(A4)..); +0x108 player-task ptr (264(A4));
+0x10c tk-style list head; +0x120 scratch channel-ctx
(288(A4)..); +0x180 ->SECSTRT_2 chip wave (384(A4), reloc
hunk2+0 via code+0x62e); +0x24c channel-token count
(588(A4)); +0x250 token array (592(A4)..); +0x260 activity
flag (608(A4)); +0x264 flag word (612(A4)).
