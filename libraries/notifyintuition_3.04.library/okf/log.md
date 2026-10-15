---
file: log
---
# Work log

- 2026-10-15: notifyintuition 3.04 — flat single-hunk
  lib, declared==physical 0x58b longs (5676B body),
  RELOC32 tail 17 slots ->h0, END. Raw .byte h0 +
  generic fixup (same as 2.40/2.41); BYTE-IDENTICAL
  on first build.
  machine68k oracle: AUTOINIT init (FindTask guard,
  OpenLibrary dos/intuition/utility, CreateNewProc
  stub NP_Entry=h0+0x33c, NewList +0x80/+0x8e,
  fake screennotify.library build + FindName/Insert
  into LibList), Open x2 (subtask respawn each Open
  since stubbed proc never registers), reserved -24,
  NotIStartNotify error matrix (102/99/100/102/100/101)
  + real registrations (hook class, named pattern ->
  ParsePattern, signal class with UniqueID),
  re-register -> -4, NotIFindUniqueTask hit (owner
  ThisTask), NotIEndNotify (Remove/FreeVec xN + mask
  rebuild), all 10 fake screennotify vectors
  (open/close/expunge/reserved + -30/-42/-54 starts,
  -36/-48/-60 shared end incl. GetMsg/ReplyMsg drain),
  Close x2, Expunge -> dead stub 0.
  RUNTIME-IDENTICAL, invalids=0.
  Harness bug found+fixed along the way: tr_allocvec
  wrote the size header at a-4 without reserving it,
  corrupting the previous node; fixed to heap+4/alloc
  (d0+7)&~3. LVO stubs -684/-690 corrected.
  Delta vs 2.41: v3r3 (26.10.97), hunk +808B,
  dataSize 0xc0->0x9c (reorganised: second MinList
  @+0x8e for in-flight replies), AllocVec for all
  request allocations, Expunge neutered to a zero
  stub, embedded screennotify.library, flag bit24 as
  port-class alias, events mask &0x1ffc0.
