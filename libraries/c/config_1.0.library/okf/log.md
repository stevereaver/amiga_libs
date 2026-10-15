# config.library 1.0 — work log

- Parsed hunk header: 2 hunks [0..1], table sizes 0x259 / 0x56 longs.
  h0 = CODE 2404 B @ file 0x24; h1 = DATA 340 B @ file 0x9d4 (own size
  field 0x55 — one longword less than the table promised).
- Extracted relocations: h0 -> hunk1 x12 (scrambled order), h1 -> hunk0
  x9 (ascending 0x124..0x144: initfn + functab), h1 -> hunk1 x9
  (scrambled).  Order preserved in `source/fixup.py`.
- Strings/RomTag all live in h1: RomTag @ h1+0xa4 (AUTOINIT, ver 3),
  rt_Init -> InitTable @ h1+0x118: dsize 0x36, functab @ h1+0x128
  (8 absolute longs + 0xffffffff), datatab @ h1+0xbe, initfn = h0+0x6fc.
- datatab uses extended (24-bit offset) InitStruct forms
  `e000/d000` interleaved with 8-bit-offset `800a/8018` longs; sets
  ln_Type=9, ln_Name, lib_Flags=6, lib_Version=3, lib_Revision=0,
  lib_IdString — library is really **3.0** despite the "1.0" idstring.
- SAS/C small-data: every function re-bases `a4 = h1+0x7ffe`; globals
  reached via negative a4 offsets into h1 (cells 0x4c-0x58, libbase
  0x14c, fmt strings 0x00-0x4b).
- Disassembled h0 fully (Capstone).  Identified: SetStr (0x0, full
  slurp-and-rewrite writer), SetNum (0x2a0, sprintf wrapper), GetStr
  (0x2de, `[section]`/`key = value` scanner), GetNum (0x47c, GetStr +
  StrToLong), list/str helpers 0x4d4-0x627, opendeps/closedeps
  0x628/0x6ae (deps: dos v37, intuition v37, graphics v37 — int/gfx
  opened but never used), initfn 0x6fc, Open/Close/Expunge/null
  0x738/0x750/0x778/0x7da, LVO shim wrappers 0x7e8-0x920, sprintf/
  RawDoFmt 0x920 + putch 0x944, reg-save stubs 0x948-0x963.
- Transcribed to `source/config_h0.s` / `config_h1.s`.  Raw `.short`
  emits used where gas would canonicalize (`pea imm` for `pea (addr)`
  modes, `movel #imm` vs moveq, `@(0)` forms).  Branched via labels.
- `Makefile` + `hunks.x` linker script (`.text`->h0, `.data`->h1),
  `fixup.py` rewrites RELOC32 groups in original order and restores the
  0x56/0x55 table quirk.  Result byte-identical on first good link:
  MD5 `3251b43caed885d8c0ba93b8ac1c3d1e` (orig = rebuild).
- `work/oracle.py`: machine68k M68020, hunks at 0x40000/0x44000,
  lib at 0x100000 linked into a minimal exec list (else Remove() on
  expunge writes through null ln_Succ/ln_Pred and clobbers absolute
  0/4 — later `moveal 4,a6` (sprintf) then wanders).  Stubbed exec
  (OpenLibrary/CloseLibrary/AllocVec/FreeVec/FreeMem/Remove/RemHead/
  AddTail/RawDoFmt) and dos (Open/Close/FGets/VFPrintf/StrToLong) with
  an in-memory file store.
- Oracle coverage: init ok + init with dos unavailable; Open/ExtFunc/
  Expunge-busy (sets DELEXP)/Close -> deferred expunge (Remove +
  CloseLibrary x3 + FreeMem(neg+pos) + seglist return); SetStr replace
  key (verified rewritten bytes incl. injected blank line before the
  next section header), SetStr new file (`[sec]\nk = v\n`), SetNum;
  GetStr hit/miss->default/tiny-buf->0/missing-file->default; GetNum
  hit/miss->default/missing-file->default/unparseable->stale cell
  (returned previous call's 1234); close again + expunge-idle.
- `work/orig.log` vs `work/rebuild.log`: identical, 146 entries,
  zero invalid-access noise.
