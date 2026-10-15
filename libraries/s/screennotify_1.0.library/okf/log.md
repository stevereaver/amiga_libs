# screennotify 1.0.library — work log

## decode

- Hunk parse: CODE 2408 B (602 longs) @0x24, 29 RELOC32
  (15 same-hunk incl. RomTag+functab, 14 into hunk 1 — the
  `lea _DATA+0x7ffe,a4` sites), END; DATA hunk body 2 longs,
  header declares 6 (24 B globals area).
- RomTag @0x44: matchtag→self, endskip→0x5e, flags 0x00 COLDSTART,
  ver 1, NT_LIBRARY, name→0x04, idstr→0x19, init→0xca.
- idstr is 43 bytes and abuts the RomTag — no pad byte (initially
  added one, RomTag drifted +1).
- functab @0x5e: 10 long-absolute vectors, `-1` terminated.
- rt_Init @0xca: MakeLibrary(functab, 0, 0, dsize=410), manual node
  fill (type 9, name, flags 6, ver 1 rev 0, idstr, seglist@36,
  intu@40=0), `_initobj` on three 122-byte objects, AddLibrary.
- `_initobj` (0x8a): NewList@+0, InitSemaphore@+14, embedded Message
  @+60 (replyport→+88, len 28), embedded MsgPort @+88 (type 4,
  flags PA_SIGNAL, NewList@+108).

## vector/API identification

- -30/-36/-42/-48/-54/-60 = register/unregister pairs for the three
  notify classes (obj0 screen-close 18 B nodes with +14=screen;
  obj1 pubstatus 14 B; obj2 workbench 14 B).
- `_install` patches intuition -66/-78/-210/-552
  (CloseScreen/CloseWorkBench/OpenWorkBench/PubScreenStatus) at first
  Open; `_uninstall` restores them at Expunge with the two-pass
  foreign-handler check.
- Broadcast helper 0x3d4: ObtainSemaphore, AllocSignal, FindTask,
  serial PutMsg+WaitPort+GetMsg per subscriber, skip same-task ports.

## build iterations

1. RomTag landed at 0x45 — idstr is 43 B (no pad byte); removed the
   extra `.byte 0`.
2. hunk-1 relocs +2 everywhere from _vec66 on — I had inserted a
   spurious `moveal a0,a3` (a3 is the embedded port, assigned later at
   obj+88); removed it.
3. `cmpb #-1,dN` emitted as `cmpi.b` (0c07/0c06) — original uses the
   legacy `cmpb #imm,dN` form (be3c/bc3c); forced `.short` opcodes.
4. Result: byte-identical, MD5 228be5ea5285cf4aa8591a2c34fb2309.

## verification

- `work/oracle.py`: fake exec (MakeLibrary/AddLibrary/OpenLibrary/
  SetFunction/MinList+Enqueue/PutMsg/ReplyMsg/GetMsg/WaitPort with
  real list semantics, sem stubs, AllocMem/FreeMem, AllocSignal) +
  fake intuition.library with real jmp slots for the six LVOs.
- Battery: init fields, open+hook install, three-class registration
  (pri-ordered Enqueue), CloseScreen broadcast (match+wildcard, skip
  same-task), PubScreenStatus all four req/res combinations +
  no-match, OpenWB ok/fail, CloseWB, unregister incl. contended-sem
  drain, nosignal path, deferred expunge, foreign-wrap abort, final
  clean expunge.
- Original vs rebuild: full logs identical; binary byte-identical.
