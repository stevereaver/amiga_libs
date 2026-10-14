# queue.library 3.1 — work log

- Parsed hunk file: 3 hunks — CODE 0x26b longs, DATA 8 longs,
  CODE 0x17 longs. Relocs: h0 -> h0 {a,6}, -> h1 {86,74,1a},
  -> h2 {5a,34,16,12}; h1 -> h0 {10}, -> h2 {8}; h2 -> h0
  {30..0 step 4} — all groups in descending-offset order.
- RomTag at h0+4: MatchTag->h0+4, EndSkip->h0+0x1e, RTF_AUTOINIT,
  ver 3, NT_LIBRARY, pri 0, name->h2+0x38, idstr->h2+0x48,
  init->h1+4.
- hunk1 is the AUTOINIT InitTable at +4 (dsize 0x8c, functab->h2+0,
  datatab 0, initfn->h0+0x20) embedded in the SAS/C globals template
  the initfn copies to lib+48.
- Identified the binary as the queue.library 3.1 build from AmiNet
  `util/libs/queue.lzh` (md5 of the archive's queue.library matches);
  pulled the shipped queue_library.c/.h/queue.fd for exact symbol and
  structure names.
- Transcribed all code verbatim to `source/queue.s`. Two overlapped
  immediates (`cmpiw #0x1cd9` / `cmpiw #0x200d`) encoded via label+2
  branch targets; forced word displacements (`bsrw`, `braw`, `:W` on
  jsr) where gas would relax to byte form; `subqw #8,sp` vs
  `subaw #8,sp` distinguished per-site (514f vs 9efc).
- Build: `make` links CODE+DATA then `fixup.py` re-splits DATA into
  hunk1 (8-long template) and hunk2 CODE (functab+strings), retargets
  reloc addends (data>=0x20 -> hunk2, -0x20) and emits RELOC32 groups
  in the original descending order. Byte-identical:
  md5 `c36710f623b4186980b10b35847dfd2a`.
- Oracle: machine68k harness, hunks at 0x40000/0x70000/0xa0000, fake
  exec at 0x1000 with real MinList semantics (Insert/AddHead/AddTail/
  Remove/RemTail/FindName/Signal/semaphores/CopyMem/AllocMem/FreeMem/
  FindTask). AUTOINIT emulation runs rt_Init through the functab.
  Exercised: init, Open, QOpen (listener+sender on same queue, second
  listener on another), QAllocMsg, QAddMsg, QGetMsg (listen+send),
  QReplyMsg, QRemMsg, QFlush, QFreeMsg, QClose incl. last-ref qnode
  teardown, deferred expunge via LIBF_DELEXP. Logs identical between
  original and rebuild.
