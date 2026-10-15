# accounts.library 37.5 — work log

- Parsed hunk file with a small python script: 1× CODE hunk,
  0x29c longs (2672B body at file 0x20), one RELOC32 group with
  8 hunk0→hunk0 offsets in the order `0xa,0x6,0x12,0x16,0x1a,
  0x4c,0x50,0x54`, then HUNK_END.
- RomTag at hunk+4 (preceded by an unreferenced `moveq #-1,rts` stub):
  4afc, MatchTag→itself, EndSkip→0xa70 (hunk end), RTF_AUTOINIT,
  ver 37, NT_LIBRARY, pri 0, name "accounts.library",
  id "accounts 37.5 (1.3.93)\r\n", init→0x48.
- InitTable: dsize=0xf4, functab→0x58, datatab→0x82, initfn→0x88.
  functab is the *word-offset* form (leading -1; 19 entries; -1 term).
  datatab is a single `INITWORD` (0x90,0x16) writing lib_Revision=5.
- Verified the functab interpretation by checking that
  ftab+offset lands exactly on instruction starts
  (0x138 addqw opencnt = Open, 0x1ec subqw opencnt = Close,
  0x244 tstw opencnt = Expunge, 0x298 ret0 = reserved).
- Full objdump disassembly (work/dis0.txt) resolved: strings at
  0xe6–0x133 (nipc/utility/"Accounts Server"/dos/"Envoy/AccountsServer")
  and a 4-byte zero taglist at 0x134 sit between initfn and Open.
- All external calls resolved via NDK lvo tables: exec
  AllocMem/FreeMem/GetMsg/WaitPort/CloseLibrary/RawDoFmt/OpenLibrary/
  InitSemaphore/ObtainSemaphore/ReleaseSemaphore/CreateMsgPort/
  DeleteMsgPort; dos GetVar(-906); utility UDivMod32(-156),
  ToLower(-180); six calls into nipc.library (-114,-120,-126,-132,
  -138,-144,-156) — names inferred (Envoy IPC lib; no nipc_lib.i in NDK).
- Identified the RPC shape: every vector allocates a request object via
  nipc -114 + tag {0x800b1101,size}, writes a command byte to obj+28,
  sends via a per-call reply port (exec CreateMsgPort→nipc -156→
  WaitPort→GetMsg→DeleteMsgPort), returns obj+30 (501 local failure),
  frees via nipc -120. Plus 40B/34B alloc/free record pairs and a
  mod-53 rolling password hash.
- Transcribed instruction-exact to `source/accounts.s` (gas).
  No canonicalization traps found; `jsr %pc@(_lbl)`, `bsrw`, `dbeq`,
  `exg %a2,%a1`, `moveb %a2@(0,%d7:l)`, `pea 0xNN:w` all emit the
  original encodings directly.
- Build: `make` → byte-identical, md5 `56b6d8fc21a9ef9b53564ab6509bc994`.
  fixup.py rewrites the hunk0 RELOC32 offset list into the original
  order (asserts the set first).
- Oracle (`work/oracle.py`, machine68k, M68000): fake exec with real
  MakeLibrary-style vector build for the word-offset functab +
  InitStruct datatab walk; fake nipc.transaction that writes a reply
  in place; exercised initfn, Open ×2, all 19 vectors, deferred
  expunge through Close (opencnt>0 + DELEXP), failure paths
  (no nipc / ctx fail / service fail / alloc fail → 501 / server
  error passthrough), the dead sprintf helper, and inline-Remove
  node unlink. orig vs rebuilt logs identical
  (`work/log_orig.txt` == `work/log_rebuilt.txt`).
