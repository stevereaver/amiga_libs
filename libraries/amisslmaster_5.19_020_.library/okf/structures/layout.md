# Layout

- File 6128B (0x17f0). Header: 2 hunks; table sizes h0=0x5bb, h1=0x34 longs.
- h0 CODE @file 0x24, 0x5bb longs (0x16ecB):
  - +0x00 `bra +0x602` over head; +0x04 "amisslmaster.library\0";
    +0x1f "$VER: amisslmaster.library 5.19 (11.2.2025) os3-68020
    version\r\n\0"; +0x04ac padding.
  - +0x5a functab: 10 abs-long vectors (+0x37a,+0x502,+0x60a,+0x63c,
    +0x1468,+0xa7c,+0xfce,+0x1090,+0x148c,+0x1538) + 0xffffffff.
  - +0x86 InitTable: dsize 0x66, ftab +0x5a, dtab 0, initfn +0xf0.
  - +0x96 extended resident (26B): 4afc, matchtag +0x96, endskip
    +0xb0, flags 0x80, ver 5, type 9, pri 0, name +4, id +0x1f,
    init +0x86.
  - +0xf0 initfn: writes node type 9/flags 6, ver 5 rev 19, name/id
    ptrs, SysBase->lib+0x30; returns 0 under stub env.
  - strings: dos.library +0xe4, "LIBS:AmiSSL/" +0x716, "_v2.library"
    +0x723, "amissl_v" +0x72f, ".library" +0x738; version-tag table
    +0x97c..+0xa29: 39 NUL-terminated tags —
    "341","340","332","331","330","321","320","314","313","312",
    "311","310","308","307","306","305","304","303","302","301",
    "300","111a","111m","111l","111k","111j","111i","111g","111d",
    "110g","110e","110d","110c","102f","101i","101h","098y","097m",
    "097g"; ciphers "amissl","blowfish","cast","des","idea","md2",
    "md4","md5","rc2","rc4","rc5","ripemd","sha","dsa","dh","rsa",
    "mdc2" +0xa2a..; utility.library +0x1446, intuition.library +0x1456.
  - last 0x1acB of h0 are byte-identical to 5.17's tail.
- h1 DATA @file 0x17cc, 8 longs content but mem size 0x34 longs
  (0xd0B): bytes 0..0x13 zero, +0x14 long 0x26 (init/state field —
  checked for ==1 by vector -48; equals the -30 compare constant 38),
  rest zero; tail 0xb0B uninitialised.
  Referenced via a4=h1base+0x7ffe with negative offsets (7 RELOC32
  into h1 patch the a4 loads): h1+0 = lib-private data, +0x8,+0x10,
  +0x14 init flag 0x26, +0x5c semaphore used by dispatcher vectors.
- RELOC32: h0 group1 31->h0 (@0x5a..0x812), group2 7->h1
  (@0xf6,0x188,0x380,0x508,0x610,0x6d4,0x6fa — 5.17's offsets
  each +2); h1 no relocs, END only.
- Library struct: dsize 0x66; +0x20 opencnt(word), +0x30 SysBase,
  +0x38 semaphore (ObtainSemaphore target), +0x2c seglist.
