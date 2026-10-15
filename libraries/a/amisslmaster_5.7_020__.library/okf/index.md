# amisslmaster_5.7(020+).library

"amisslmaster.library 5.7 (7.2.2023) os3-68020 version" — AmiSSL-5
master/dispatcher library, 68020+ build. 5844B.

- 2 hunks: h0 CODE (0x574 longs; entry `bra` over the string/tag head,
  resident mid-hunk @h0+0x94), h1 DATA (8 longs content, header mem
  size 0x34 longs — 176B uninitialised tail = the library's
  a4-relative near-data area; contents are zeros + long 0x20 @+0x14,
  i.e. **not** the executable stub bytes the 5.1 notes hinted at).
- Extended 26B resident (flags 0x80 AUTOINIT, type 9 NT_LIBRARY,
  pri 0); name ->h0+4 "amisslmaster.library", id ->h0+0x1f,
  init ->h0+0x84.
- InitTable @h0+0x84: dsize 0x66, ftab->h0+0x58 (10 abs-long vectors,
  -1 term), dtab 0, initfn->h0+0xee.
- Relocs: h0 group1 31->h0, group2 7->h1; h1 none. The 7->h1 relocs
  patch `lea #0x7ffe,a4` / near-data slots: a4 := h1base+0x7ffe, all
  data refs are a4@(-0x7ffe+off) (SAS/C-style small-data window).
- Strings/deps: dos.library (+0xe2), utility.library (+0x132a),
  intuition.library (+0x133a); sublib search path "LIBS:AmiSSL/" +
  "_v2.library" / "amissl_v" + ".library", tag table
  308,111a..097g; cipher names blowfish/cast/idea/ripemd/mdc2.
  No iffparse string (unlike the 5.1 oracle comment's list).
