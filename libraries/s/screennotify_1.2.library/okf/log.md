# screennotify.library 1.2 — RE log

- Identified next smallest pending lib: 1852 bytes,
  `screennotify.library 1.2 (18.1.2005)`, deps intuition/graphics/dos.
- IRA disasm -> `work/screennotify.asm`. AUTOINIT, word-offset
  functab (10 vectors), dataSize 0x386.
- Decoded lifecycle: Open/Close trivial; Expunge = 4-stage verified
  SetFunction unchain + worker Signal + Remove + FreeMem.
- Decoded init: OpenLibrary intu/dos v37, CreateMsgPort, AllocVec
  0x9c + CopyMem worker image, CreateNewProcTagList
  (NP_Entry/NP_Name -> image+136 "scn service process"), PutMsg
  handshake -> worker port @+84, NewList+InitSemaphore x3 list
  blocks, CopyMem 0x1b0 patch image -> lib+470, Forbid,
  SetFunction x4 (OSTL -612, CS -66, CWB -78, PSS -552), Permit,
  CacheClearU, OpenLibrary gfx v37 (last — needed for WaitTOF in
  the add-client retry loop).
- Decoded patch image: 4 hooks + synchronous broadcast walker +
  node iterator. PC-relative refs use the +0x35a shadow layout so
  the copy lands on lib base fields (exec@40, msg@56, ctx@84,
  flag@34, lists@88/210/332, old vecs@454-466); the displacement
  table shares bytes with "scn service process".
- Resolved all calls: exec (FindTask/Wait/WaitPort/GetMsg/PutMsg/
  ReplyMsg/Signal/AllocMem/AllocVec/FreeVec/FreeMem/CopyMem/
  Enqueue/Remove/InitSemaphore/Obtain/Release/AttemptSemaphore/
  OpenLib/CloseLib/CreateMsgPort/DeleteMsgPort/SetFunction/Forbid/
  Permit/CacheClearU/Remove), dos (-198 Delay, -498
  CreateNewProcTagList), gfx (-270 WaitTOF), intuition (-522
  LockPubScreenList, -528 UnlockPubScreenList inside patches).
- Reconstructed: `screennotify.c` (lifecycle + client add/remove),
  `screennotify_lib.s` (skeleton + verbatim worker/patch images
  with .set shadow symbols).
- Verified: header+datatab+strings byte-identical (mod relocs);
  worker image byte-identical; patch image identical except one
  equivalent branch disp; all offsets + vectors checked in the
  objdump.
- Defects recorded in findings/defects.md.
