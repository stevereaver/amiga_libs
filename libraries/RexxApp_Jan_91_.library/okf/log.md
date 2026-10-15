# RE log — rexxapp.library

- Verified `RexxApp_Jan_91_.library` == `rexxapp__Jan_91_.library`
  (byte-identical, md5 1724406df58c813c7db58aef2ff35320). One canonical
  source/OKF bundle kept under `RexxApp_Jan_91_.library`.
- IRA/objdump full disassembly; identified ARexx host library, not a
  generic function library. All 14 vector slots resolved (4 nulls).
- Mapped exec LVOs: -330 AllocSignal, -336 FreeSignal, -354/-360
  AddPort/RemPort, -366/-372/-378/-384/-390 PutMsg/GetMsg/ReplyMsg/
  WaitPort/FindPort, -132/-138 Forbid/Permit, -396 AddLibrary,
  -414/-552 Close/OpenLibrary, -252 Remove.
- Mapped rexxsyslib LVOs: -126 CreateArgstring, -132 DeleteArgstring,
  -144 CreateRexxMsg, -150 DeleteRexxMsg, private -96 (argstring
  resolve for result callback).
- Decoded context ABI: caller-owned ctx in A5, embedded MsgPort,
  verb table +62, three distinct callback conventions.
- Reconstruction `rexxapp.c` + `rexxapp_lib.s`: byte-exact header
  (stub/RomTag/node/init through 0xd6); C semantics audited against
  disasm — fixed a5 clobber (`-ffixed-a5`), -66 vector retargeted to
  the setresult store, stack-arg callback convention (moveml masks
  0x80a4/0x0024 byte-identical), verb-fold boundary (97,122) exclusive,
  cleanup re-dispatch loop, setup a0 error string, createmsg-fail
  freemsg path.
- Build: m68k-amigaos-gcc, links clean; all 14 jmps `4ef9` absolute,
  reloc parity (all original fixup sites present).
- 2025-10: C hybrid replaced by verbatim-asm `source/RexxApp_h0.s`
  (same transcription already proven on sibling rexxapp__Jan_91_).
  GNU as+ld emit the hunk0 body + all 21 RELOC32 fixups in original
  order; `source/fixup.py` rewrites the header num=1→2 / last=0→1 /
  adds hunk1-size 0 and appends the trailing `3e9/0/3f2` empty CODE
  hunk.  `cmp` byte-identical (md5 1724406df58c813c7db58aef2ff35320).
- machine68k oracle `work/oracle.py` (CPUType.M68020): hunk loader
  applies RELOC32; trap stubs for exec (-132..-552) and rexxsyslib
  (-96/-126/-132/-144/-150); MakeLibrary installs neg/pos image;
  exercises init, all 14 LVOs, name-collision retry (myport→myport3),
  reply/incoming/shutdown dispatch, verb fold probes, send ok/fail
  paths, validator veto, setresult store+argstring, cleanup drain,
  deferred expunge.  orig.log == rebuild.log.
- Oracle probing corrected the fold-quirk claim: guard is folded
  input char in ['a','z'] *inclusive* ('a' AND 'z' fold-match;
  '{'/'`' do not).  Prior "(97,122) exclusive" reading was wrong —
  `subb d1,d0;bhi` bounds c1≥97 and `cmpib #122,d1;bls` bounds c1≤122.
