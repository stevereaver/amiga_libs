---
file: vectors
---
# Vectors

6 LVOs (-6 .. -36), absolute-longword functab @h0+0x70,
terminated by -1L:

| LVO | code off | name | notes |
|-----|----------|------|-------|
| -6  | 0x198 | Open   | opencnt++, clear LIBF_DELEXP (flag bit 3), return base |
| -12 | 0x1b0 | Close  | opencnt--; at 0 with DELEXP -> calls expunge path, returns its seglist |
| -18 | 0x1e6 | Expunge| opencnt>0 -> set DELEXP, ret 0. lib+34==0 -> Remove(-252) + FreeMem(-210) of base-NegSize, NegSize+PosSize bytes, ret seglist (lib+36). lib+34!=0 -> Signal(lib+40, 0x1000) via -324, set DELEXP, ret 0 |
| -24 | 0x26a | reserved | `moveq #0,d0;rts` (shared with -30) |
| -30 | 0x26a | reserved | same stub, returns 0 |
| -36 | 0x2b8 | WBStart | see below |

## WBStart(a0=taglist) -> d0

- AllocSignal(-1) (-330), fail -> 20.
- ObtainSemaphore(lib+48), signal# -> lib+111, FindTask(0) ->
  lib+112.
- If lib+34==0 (handler down): OpenLibrary("dos.library",39),
  CreateNewProc(-498) with embedded taglist @h0+0x8c
  (NP_Entry->0x3d0, NP_Name+NP_CommandName "WBStart Handler",
  NP_Cli=1), proc -> lib+40; handshake packet lib+132 to
  proc pr_MsgPort (+92), reply via embedded port lib+96; reply
  field (msg+10)==0 -> lib+34=1.  CloseLibrary(dos).
- If lib+44 (handler's port block): a0 stored at lib+142, packet
  round trip (PutMsg/WaitPort/GetMsg helper @0x26e) to the
  handler; result = msg+10 -> d0.
- ReleaseSemaphore, FreeSignal; return d0 (0 ok / 20 fail).

## Internal entry (not a vector)

- `handlerentry` 0x3d0 — the "WBStart Handler" process main,
  reached via NP_Entry in the CreateNewProc taglist.
- `pktrt` 0x26e — PutMsg(port,msg)+WaitPort(reply)+GetMsg(reply),
  returns msg+10.
- Helpers: 0x608 CreatePool wrapper, 0x63a DeletePool,
  0x64c AllocPooled(size+4, size stored at -4), 0x676 FreePooled,
  0x698 name->lock via dos Lock/dospath -54, 0x6e4 cli_CommandDir
  hijack (Cli + dospath -78/-36), 0x74c restore, 0x81c argpair
  fan-out (DupLock each), 0x886 lock-path resolve (FilePart/
  Lock/DupLock/CurrentDir/SameLock/ParentDir/UnLock), 0x9b6
  icon GetDiskObject(-78)/FreeDiskObject(-90) + CurrentDir,
  0xbe4 startobj -> NewLoadSeg(-768) + CreateNewProc stack-built
  NP_ taglist (template @h0+0x79c), 0xe32 child cleanup
  (UnLoadSeg -156), 0xea0/0xef0 CreateNewProc wrapper,
  0xeb4 strlen, 0xec4 strcpy, 0xedc/0xee0 NewList, 0xef0
  dos -498 dispatcher.
- Dead/pad tail 0xf00..0xf1b: 4x `moveq #0/1;rts`, nops/rts.
