# rebol 0.2.library — work log

- Hunk parse: header 0x3f3, one CODE hunk 0x2b7 longs (2780 B) at
  file 0x20..0xafc; RELOC32 with 19 offsets in non-sorted order;
  total file 2908 B, MD5 8248998dac7f1d1b5f236fb67fc12745.
- RomTag @0x04: AUTOINIT, ver 0, NT_LIBRARY; endSkip -> 0x1fe.
  InitTable @0x1e: dsize 0x2c, functab @0x730 (6 absolute longs),
  datatab @0x2e, initfn @0x4e.
- Identity confirmed against Aminet RebolLib (07.07.2001, Jean
  Holzammer): archive `rebol.library` is byte-identical to ours.
  Public API: RebolDo(-30), RebolFreeResult(-36).
- Full disasm: C-compiled library (link/unlk frames, counted stack
  buffers, ctx pointer in a4, per-task slot list in lib+38).
  Internal helpers mapped: _findslot/_newslot/_ctxinit/_ctxfree,
  _findctx, _reboldo, _freecore, _fmt/_putch (RawDoFmt wrapper),
  _strtol (-/$hex/%bin/dec, embedded pow10 table), _filesize
  (Lock/Examine/FIB), _fputs (RawDoFmt+FPuts, CON: fallback),
  _readfile, _closecon.
- Transcription to source/rebol.s: fixed GAS relaxation points
  (pea (d16,PC), movel d0,sp@(0) zero-disp, CMP-imm EA vs CMPI,
  bset d2,d1, abs jsr/jmp, moveal 4:w, bsr.w vs bsr.b), the
  missing `)` in the idstring, and the `_declp` label offset.
- Build: `m68k-amigaos-gcc -m68000 -c` + link `-nostdlib -s`,
  fixup.py rewrites hunk tail to original RELOC32 order.
  Result: byte-identical, MD5 8248998dac7f1d1b5f236fb67fc12745.
- Oracle (work/oracle.py): machine68k M68020, hunk load + reloc,
  exec stubs (AllocMem/FreeMem/AllocVec/FreeVec/Forbid/Permit/
  OpenLibrary/CloseLibrary/Remove) + a real injected m68k RawDoFmt
  (putch callback must run inside the emulation); dos.library stubs
  (Open/Close/Read/DeleteFile/Lock/UnLock/Examine/FPuts/
  SystemTagList/SetVar/GetVar); ThisTask via SysBase+276.
  Exercised: init, header fields, Open x2 (slot reuse), -24 stub,
  RebolDo full pipeline (count bump -> script fmt -> script Open ->
  wrapper FPuts -> cmd fmt -> SystemTagList -> result Open ->
  Lock/Examine -> AllocVec -> Read -> Close/Delete), RebolFreeResult
  incl. 0, GetVar-fail (count=1), script-Open-fail (result still
  read), result-Open-fail (->0), Lock-fail (filesize -1),
  AllocMem-fail Open (corrupt $4 path), Close-to-zero deferred
  expunge, direct Expunge, post-expunge calls with no ctx.
- orig.log == rebuilt.log (byte-for-byte identical traces,
  including the INVALID writes on the corrupt path).
