# mcpsupport2.library — reconstruction log

## 2026-10-28 — reverse engineering + reconstruction

### Binary inspection
- 1392-byte single CODE hunk, AUTOINIT, ver 5.
- InitTable @ hunk 0x78: dataSize 0x22 (plain Library),
  FUNCTABLE @ 0x88 (8 LONG vectors), DATATAB @ 0xac,
  INITFUNCTION @ 0xcc.
- aux block: INIT AllocMem(12, MEMF_CLEAR|CHIP?) and stores
  seglist@0, then OpenLibrary("dos.library",37)@4 and
  OpenLibrary("utility.library",36)@8.

### Functions
- `-30 mcpLoadFile`: Lock(ACCESS_READ) -> AllocDosObject(FIB)
  -> Examine -> fib_Size -> FreeDosObject -> AllocVec(size+1)
  -> Open(MODE_OLDFILE) -> Read -> buf[size]=0 -> Close ->
  UnLock.  Returns d0=buf, d1=size (0/0 on failure).
- `-36 mcpCmdNameBuf` / `-42 mcpCmdName`: Forbid; resolve the
  task (a0 or FindTask(NULL)); require ln_Type==NT_PROCESS
  (0x0d); follow pr_CLI (bcpl@172) -> cli_CommandName
  (bcpl@16) -> BSTR; validate the length byte; optionally
  strip to basename when flags&1.  Buf variant copies into
  dest[len]; ptr variant returns the pointer.
- `-48 mcpMatch`: recursive wildcard matcher (~,(),|,? ,#)
  using utility ToUpper(-174).

### Reconstruction
- `mcpsupport2_lib.s`: RomTag, exact InitStruct datatab
  (ver5/rev0 — NOT 5.2 despite the filename), INITFUNCTION,
  8-vector FUNCTABLE, aux block + lib/dos/util/$VER strings.
- `mcpsupport2.c`: framework + 4 functions via LVO macros;
  the cmd-name walk uses dos/dosextens Process/CLI fields.
- The wildcard matcher is a functional-equivalent recursive
  implementation (the original's control-flow is a hand-
  rolled SAS/C state machine); 21 host cases all pass.

### Verification
- Built 1740 bytes, single CODE hunk.
- datatab byte-identical; functab 8 vectors same order.
- LVO call inventory matches the original exactly.
- mcpLoadFile leaves size in d1 (verified in the disasm:
  `movel d3,d1; movel d5,d0; rts`).

### Shipped defects (see findings/)
- Expunge frees the aux block + base but NEVER CloseLibrary'd
  the dos/utility bases -> their open counts leak.
- The "5.2" filename vs internal "5.0" reporting.
