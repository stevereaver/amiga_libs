# amisslmaster_5.19(020).library

"amisslmaster.library 5.19 (11.2.2025) os3-68020 version" — AmiSSL-5
master/dispatcher library, 68020+ build. 6128B. Direct descendant of
5.17(020+): same hunk plan, +0x34B more code, expanded version-tag table.

- 2 hunks: h0 CODE (0x5bb longs; entry `bra` over the string/tag head,
  resident mid-hunk @h0+0x96), h1 DATA (8 longs content, header mem
  size 0x34 longs — 176B uninitialised tail = the library's
  a4-relative near-data area; contents are zeros + long 0x26 @+0x14
  [5.17 shipped 0x24, 5.7 0x20, 5.1 0x15] — required sublib-version
  threshold, mirrored as the immediate in the -30 compare).
- Extended 26B resident (flags 0x80 AUTOINIT, type 9 NT_LIBRARY,
  pri 0); name ->h0+4 "amisslmaster.library", id ->h0+0x1f,
  init ->h0+0x86.
- InitTable @h0+0x86: dsize 0x66, ftab->h0+0x5a (10 abs-long vectors,
  -1 term), dtab 0, initfn->h0+0xf0.
- Relocs: h0 group1 31->h0, group2 7->h1; h1 none. The 7->h1 relocs
  patch `lea #0x7ffe,a4` / near-data slots: a4 := h1base+0x7ffe, all
  data refs are a4@(-0x7ffe+off) (SAS/C-style small-data window).
- Strings/deps: dos.library (+0xe4), utility.library (+0x1446),
  intuition.library (+0x1456); sublib search path "LIBS:AmiSSL/" +
  "_v2.library" / "amissl_v" + ".library"; version-tag table
  @+0x97c: 39 NUL-terminated tags "341","340" (new vs 5.17) then
  "332","331","330","321","320","314","313","312","311","310",
  "308".."097g" as before; cipher names amissl/blowfish/cast/des/idea/
  md2/md4/md5/rc2/rc4/rc5/ripemd/sha/dsa/dh/rsa/mdc2 +0xa2a..;
  h0 tail 0x1acB byte-identical to 5.17.
  No iffparse string.
