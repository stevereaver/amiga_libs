# cachefile.library 1.67 — work log

## Session: reverse engineering + C reconstruction

- Parsed hunk layout: single CODE hunk, 1580 bytes.
- RomTag: RTF_AUTOINIT, version 1, NT_LIBRARY, pri 0.
- InitTable: dataSize 0x76, functab @ 0xa0 (11 LONG vectors + -1L),
  datatab @ 0xd0, initfunc @ 0xf8.
- Strings: name `cachefile.library`, id `assembler/library/cachefile
  1.67 (25.8.94)`, `© Ralph Schmidt 1993`, process name
  `CacheFile_Notify`, `dos.library`.
- initfunc decoded: stores libbase @ hunk+0xf0 static, SysBase +36,
  seglist +44; OpenLibrary("dos.library") → Alert 0x38007 on failure;
  NewList(+94); InitSemaphore(+48); patches NP_Seglist tag data with
  BPTR(hunk+0x238); CreateNewProc spawns embedded daemon.
- Functab vectors: -18 and -24 are `return 0` stubs; real expunge at
  0x1c2 is dead code (no vector reaches it).
- Daemon @ 0x23c fully decoded: publishes ThisTask @ hunk+0xf4,
  CreateMsgPort → base+110, waits on portmask + sigbit 12 (quit),
  batched same-NR reply drain, walks node list, Open+reload via -36,
  frees stale node via -42, opencnt++/-- around work.
- API functions decoded: -30 find (fold incl. high-ASCII), -36 load
  (Seek-size + AllocVec + Read + NameFromFH + StartNotify + AddTail),
  -42 free (EndNotify/Remove/FreeVec), -48 freeall (deadlocks),
  -54 getlist, -60/-66 accessors; helper 0x574 frees all nodes for
  the dead expunge.
- Semaphore helpers: 0x330 obtain, 0x33c release, 0x348 versioned
  shared-obtain shim (V39+ ObtainSemaphoreShared, else attempt chain),
  0x37e release.
- Reconstruction: hand asm for header/lifecycle/daemon/helpers
  (`cachefile_lib.s`), all seven API functions + freenodes in C
  (`cachefile.c`, `-ffixed-a5`, named-register ABI a6=base / a5=base
  for helpers).
- Verified: all fixed asm regions byte-identical to original; daemon
  identical except bsrw displacements to relocated C functions;
  functab resolves correctly; single hunk.
