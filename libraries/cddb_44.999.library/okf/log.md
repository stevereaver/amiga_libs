# cddb.library 44.999 — RE log

- Parsed Hunk: h0 CODE 622 lw @ file 0x24, h1 DATA 26 lw @ 0xa44.
  h0->h0 relocs: 14 (RomTag fields + init name/idstr + 8 functab);
  h0->h1: {0x86,0x74,0x1a} (init h1 refs + rt_Init); h1->h0: 16
  (functab/initfn + 14-entry ptr table).
- RomTag @ h0+4: AUTOINIT, v44, NT_LIBRARY, init->h1+4.
- InitTable @ h1+4: dsize 0x9c, ftab->h0+0x868, dtab 0,
  initfn->h0+0x20 (hand-rolled, no InitStruct).
- Disassembled all of h0: initfn (ctx copy loop + fixup + openlibs),
  Open/Close/Expunge, -30 query, -36 stub, -42 discid, -48 errstr,
  helpers (_strncpy, _discid, _dsum, _cddbid, _runlist, _sdiv,
  _divmod). Error string table at h0+0x716.., referenced by h1 table.
- Resolved LVOs: exec -552/-414/-252/-210; utility -36/-102;
  freedb -36/-48/-60/-72/-96/-114/-126; tags 0x80000001-8 +
  0xfec9xxxx vendor range.
- Transcribed to asm (source/cddb_h0.s, cddb_h1.s). Fixes during
  bring-up: constant `lea` needed abs.l raw emission (43f9);
  missing pad between "cddb.library" and "44.999" strings;
  functab[3] = relocated h0+0 DOS stub; _discid calls _cddbid;
  clrb dst disp -1; h1 reloc tail order 0x8,0x10; rt_Init IS a
  h0->h1 reloc (0x1a).
- Build: `make` -> cddb.library 2816 B, byte-identical,
  MD5 35f2dd379949c90b8e7f65d0205c8993.
- Oracle (work/oracle.py): fake exec/utility/freedb. Verified:
  ctx copy lands correctly (errtab[0] -> "No Error!"), cursor
  fixup -> &ctx[0x4c], discid -42 -> 0x103a9803 on 3-track disc,
  -30 full sequence (ut36 x7, fd48, fd126, fd96, fd60),
  deferred expunge on last close. Original vs rebuild traces
  identical (diff clean).
