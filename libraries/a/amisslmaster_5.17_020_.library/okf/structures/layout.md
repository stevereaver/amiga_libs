# Layout

- File 6076B (0x17bc). Header: 2 hunks; table sizes h0=0x5ae, h1=0x34 longs.
- h0 CODE @file 0x24, 0x5ae longs (0x16b8B):
  - +0x00 `bra +0x602` over head; +0x04 "amisslmaster.library\0";
    +0x19 "$VER: amisslmaster.library 5.17 (4.9.2024) os3-68020
    version\r\n\0"; +0x04ac padding.
  - +0x58 functab: 10 abs-long vectors (+0x378,+0x500,+0x608,+0x63a,
    +0x1434,+0xa70,+0xf9a,+0x105c,+0x1458,+0x1504) + 0xffffffff.
  - +0x84 InitTable: dsize 0x66, ftab +0x58, dtab 0, initfn +0xee.
  - +0x94 extended resident (26B): 4afc, matchtag +0x94, endskip
    +0xae, flags 0x80, ver 5, type 9, pri 0, name +4, id +0x1f,
    init +0x84.
  - +0xee initfn: writes node type 9/flags 6, ver 5 rev 17, name/id
    ptrs, SysBase->lib+0x30; returns 0 under stub env.
  - strings: dos.library +0xe2, "LIBS:AmiSSL/" +0x712, "_v2.library"
    +0x71f, "amissl_v" +0x72b, ".library" +0x734; version-tag table
    +0x978..+0xa1d: 37 NUL-terminated 4-char tags —
    "332","331","330","321","320","314","313","312","311","310",
    "308","307","306","305","304","303","302","301","300","111a",
    "111m","111l","111k","111j","111i","111g","111d","110g","110e",
    "110d","110c","102f","101i","101h","098y","097m","097g";
    ciphers "amissl","blowfish","cast","idea","ripemd","mdc2"
    +0xa1e..; utility.library +0x1412, intuition.library +0x1422.
  - last 0x40B of h0 are byte-identical to 5.7's tail.
- h1 DATA @file 0x1798, 8 longs content but mem size 0x34 longs
  (0xd0B): bytes 0..0x13 zero, +0x14 long 0x24 (init/state field —
  checked for ==1 by vector -48; equals the -30 compare constant 36),
  rest zero; tail 0xb0B uninitialised.
  Referenced via a4=h1base+0x7ffe with negative offsets (7 RELOC32
  into h1 patch the a4 loads): h1+0 = lib-private data, +0x8,+0x10,
  +0x14 init flag 0x24, +0x5c semaphore used by dispatcher vectors.
- RELOC32: h0 group1 31->h0 (@0x58..0x80e), group2 7->h1
  (@0xf4,0x186,0x37e,0x506,0x60e,0x6d2,0x6f8 — identical offsets
  to 5.7); h1 no relocs, END only.
- Library struct: dsize 0x66; +0x20 opencnt(word), +0x30 SysBase,
  +0x38 semaphore (ObtainSemaphore target), +0x2c seglist.
