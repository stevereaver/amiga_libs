---
file: log
---
# Work log

- 2026-10-16: Parsed two-hunk module (4032B): CODE 0x3c7 longs
  @0x24, DATA 1-long body @0xfb8 (hunk table allocs 0xa).  Plain
  HUNK_RELOC32 tail on CODE, non-sorted groups:
  hunk0 {5c 58 64 68 6c 70 74 78 80 7c 84 d0 a0 90 408},
  hunk1 {2be 1ec 1b6 19c e6 3d6}.
- Packed 26-byte RomTag at code+0x56, rt_Flags=0 (non-AUTOINIT);
  rt_Init -> code+0xde initfn.  functab at +0x70: 6 absolute
  longs {198 1b0 1e6 26a 26a 2b8} + -1L.  Two NP_ taglists
  embedded as data (+0x8c handler proc, +0x79c client template).
- initfn: exec V39 check, stores SysBase at DATA+4, MakeLibrary
  (dataSize 0x98, no InitStruct/initFn), fills Node/Library
  fields by hand, NewList(lib+116) [port list], InitSemaphore
  (lib+48), AddLibrary, libbase -> DATA+0.
- Decode: Open/Close/Expunge with DELEXP dance; Expunge signals
  the handler task (lib+40) with 0x1000 when it is running;
  WBStart(-36) AllocSignal + ObtainSemaphore(lib+48) +
  message-passed dispatch to the handler process (port block at
  lib+44, reply port embedded at lib+96, msg at lib+132/142).
- Handler @0x3d0: dos/icon/utility v39 + CreatePool + signal +
  pooled MsgPort block; hijacks cli_CommandDir via
  dospath.library -78 (restore + -36 on exit); message loop:
  type!=7 -> startobj (0xbe4: tags +1 name, +2 lockstr,
  +3 lockBPTR, +4 stack>=0x1000, +5 pri, +6 nargs, +7 argpairs;
  GetDiskObject, NewLoadSeg, CreateNewProc w/ NP_Seglist/
  StackSize/Name/Priority/HomeDir + child startup msg PutMsg to
  proc pr_MsgPort); type 7 -> child-finished teardown
  (UnLoadSeg/FreePooled); exits on signal bit 12 once the
  pending count drains; leaves Forbid held (quirk).
- Reconstruction: `source/wbstart_h0.s` = raw `.short` words +
  `.long sym` at relocated slots (15 ->h0, 6 ->h1 `wbsdata`
  +0x7ffe); `fixup.py` splices the shipped RELOC32 tail and
  hunk table verbatim after verifying body+reloc-set equality
  (covers the DATA alloc 0xa vs body 1 long discrepancy).
  `make` -> BYTE-IDENTICAL (sha256 as shipped).
- machine68k oracle (`work/oracle.py`): emulates MakeLibrary
  for the non-AUTOINIT path, full port-queue model; exercises
  init, all 6 vectors, cold WBStart (handler CreateNewProc +
  handshake), request WBStart, deferred expunge (Signal), a full
  handler run (startup+request+shutdown), final expunge
  (Remove+FreeMem 188B).  orig.log == rebuild.log.
