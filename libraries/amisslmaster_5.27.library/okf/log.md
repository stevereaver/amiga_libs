# amisslmaster_5.27.library — work log

- Parsed container: HUNK_HEADER 2 hunks (CODE 1576B + DATA 44B),
  RELOC32 (10 into hunk0, 1 hunk0->hunk1 for functab), full SYMBOL
  hunk shipped in the binary (function names + `__debug_*` markers).
- Symbols gave the API surface: mLibInit/mLibOpen/mLibClose/
  mLibExpunge/mLibNull + InitAmiSSLMaster/OpenAmiSSL/CloseAmiSSL/
  OpenAmiSSLCipher/CloseAmiSSLCipher/OpenAmiSSLTagList.
- Decoded: compiled-C code (stack args, pea/jsr), writes debug lines
  to RAM:awmaster.log via DOSBase@+46; opens amissl.library lazily
  into +42; tag-walk in OpenAmiSSLTagList with literal
  ti_Data+8 chains and tags 0x80000010 (InitAmiSSL) / 0x8000000d
  (BasePtr out).  Non-standard RomTag (extra long -> logname,
  endskip -> self).
- Reconstruction: `source/amisslmaster.c` + `amisslmaster_lib.s`;
  m68020 (original uses `mulul`/`divul`).  Not byte-identical
  (original also ships sym/debug hunks; C codegen differs) —
  behavioral parity instead.
- Oracle: `work/oracle.py` — fake exec/dos/amissl stubs; logfile
  captured and compared byte-for-byte; taglist matrix (NULL, init=1
  rc0/rc1, init=0+BasePtr, init=0-nobp, tag-3 chain), lifecycle +
  deferred expunge, negative-value itoa.  orig.log vs rebuild.log
  identical.
