# amisslmaster_5.17(020).library

"amisslmaster.library 5.17 (4.9.2024) os3-68020 version" — AmiSSL-5
master/dispatcher library, 68020+ build. 6076B. Direct descendant of
5.7(020+): same hunk plan, +0xe8B more code, expanded version-tag table.

- 2 hunks: h0 CODE (0x5ae longs; entry `bra` over the string/tag head,
  resident mid-hunk @h0+0x94), h1 DATA (8 longs content, header mem
  size 0x34 longs — 176B uninitialised tail = the library's
  a4-relative near-data area; contents are zeros + long 0x24 @+0x14
  [5.7 shipped 0x20, 5.1 0x15] — required sublib-version threshold,
  mirrored as the immediate in the -30 compare).
- Extended 26B resident (flags 0x80 AUTOINIT, type 9 NT_LIBRARY,
  pri 0); name ->h0+4 "amisslmaster.library", id ->h0+0x1f,
  init ->h0+0x84.
- InitTable @h0+0x84: dsize 0x66, ftab->h0+0x58 (10 abs-long vectors,
  -1 term), dtab 0, initfn->h0+0xee.
- Relocs: h0 group1 31->h0, group2 7->h1; h1 none. The 7->h1 relocs
  patch `lea #0x7ffe,a4` / near-data slots: a4 := h1base+0x7ffe, all
  data refs are a4@(-0x7ffe+off) (SAS/C-style small-data window).
- Strings/deps: dos.library (+0xe2), utility.library (+0x1412),
  intuition.library (+0x1422); sublib search path "LIBS:AmiSSL/" +
  "_v2.library" / "amissl_v" + ".library"; version-tag table
  @+0x978: 37 entries "332","331","330","321","320","314","313",
  "312","311","310" (new vs 5.7) then "308".."097g" as before;
  cipher names amissl/blowfish/cast/idea/ripemd/mdc2 +0xa1e..;
  h0 tail 0x40B byte-identical to 5.7.
  No iffparse string.
