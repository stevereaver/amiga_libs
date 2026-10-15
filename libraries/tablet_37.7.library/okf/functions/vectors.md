---
type: Functions
title: tablet 37.7 vector map
---

# Vector map (functab h0+0xca4, 8 absolute longs -> h0, 0 hole)

-6  Open          h0+0xde  — opencnt++ @a6+0x20; bclr #3,a6+0xe
                  (clears LIBF_DELEXP); returns a6.
-12 Close         h0+0xfa  — opencnt--; on 0 with LIBF_DELEXP set
                  bsr into Expunge; returns its d0 (seglist) else 0.
-18 Expunge       h0+0x124 — sets LIBF_DELEXP; if opencnt==0:
                  cleanup h0+0x2aa (installer worker arg=0),
                  exec Remove(-252), FreeMem(-210) of neg+pos;
                  returns seglist (a6+0x22).
-24 Reserved      h0+0x00  — functab entry is 0: exec keeps the
                  default vector; h0+0 holds a `moveq #0,d0;rts`
                  stub.
-30 AllocTablet   h0+0x340 — a0 = client TagItem list.  Allocs a
                  68B block + an 80B block, creates a reply
                  MsgPort (h0+0xd4c helper) + 36B ioreq/message,
                  Forbid/PutMsg(-366) it to the 'APCommand' driver
                  port, Permit + WaitPort(-384)/GetMsg(-372) drain
                  loop until the same msg returns.  Clones the
                  taglist via utility NextTagItem(-48) into the
                  80B buffer (ti_Data zeroed).  AddTail(-246)s the
                  block onto the priv+0x128 client list.  Returns
                  block+8 as the handle (0 on failure; partial
                  frees via h0+0xd0c).
-36 FreeTablet    h0+0x532 — a0 = handle.  ObtainSemaphore
                  (priv+0xfa sem) walk priv+0x128 list for
                  node+8==handle, Remove(-252), ReleaseSemaphore;
                  sends the node's msg to 'APCommand' and drains
                  the reply (Forbid/FindPort/PutMsg/Permit/
                  WaitPort/GetMsg); frees reply port, 80B tag
                  buffer, 68B block.
-42 GetTabletData h0+0x692 — a0 = handle, a1 = caller 24B out
                  buffer.  Two paths on utility.library version
                  (priv+0xc4 +20):
                  >=39: Forbid; if handle+52 (live 24B sample buf
                  @priv+0x140) nonzero CopyMem(-624) 24B -> a1;
                  Permit; return 1 (0 if no buffer).
                  <39: ObtainSemaphore priv+0xcc; walk priv+0x134
                  pool list matching node+8/node+12 vs handle+36/
                  +40 (else use tailpred priv+0x13c); copy
                  node+16..+31 -> a1+4..+19; then iterate the
                  caller taglist at a1+20 via NextTagItem(-48):
                  ti_Tag 0x8003a006 -> node+32, 0x8003a007 ->
                  node+36 (0x8003a00x = TD_ tablet tags;
                  FindTagItem(-30) used when node+60&1);
                  ReleaseSemaphore; return flag word.
-48 TabletCommand h0+0x894 — d0 = command arg.  Creates an anon
                  reply port (h0+0xd4c), builds a 52B msg on the
                  stack (type byte 5, arg extl'd), Forbid,
                  FindPort(-390) 'APCommand', PutMsg(-366),
                  Permit, WaitPort/GetMsg until the msg replies,
                  frees the port (h0+0xd0c), returns d0.

Vector names inferred (no symbols): UAE's tablet.library stub
(PUAE src/tabletlibrary.c) implements the same -30/-36/-42
triple as alloc/free/do with the identical 24B TabletData layout
{w,w,x,y,maxx,maxy} + tag ptr.

## Helpers (h0)

0x188 returns a4 (private-data base getter); 0x18c trampoline
jsr a0@(12) with a4=a0@(16) (stored priv+0x148); 0x1a0 sub-init
(openlibs, pool alloc, sem init, installer call); 0x2aa sub-
cleanup (uninstaller call, pool freemem, CloseLibrary);
0x2f0 sem-guarded RemTail/AddHead msg pump (stored priv+0x14c);
0x964 install/uninstall worker (arg 1/0); 0xbe6 alloc 48B reply-
msg wrapper; 0xc32 free it; 0xc54/0xc8c input handlers for
intuition v37/v39 (copy a0+14/+18 -> a1+72/+76, tail-jump into
intuition+0x780/+0x716 via pushed return); 0xcf8 NewList;
0xd0c MsgPort destroyer; 0xd4c MsgPort creator (AllocSignal,
34B, FindTask self, AddPort iff named).

## External LVOs observed

exec: -132 Forbid, -138 Permit, -198 AllocMem, -210 FreeMem,
-240 AddHead, -246 AddTail, -252 Remove, -264 RemTail,
-294 FindTask, -330 AllocSignal, -336 FreeSignal, -354 AddPort,
-360 RemPort, -366 PutMsg, -372 GetMsg, -384 WaitPort,
-390 FindPort, -414 CloseLibrary, -444 OpenDevice,
-450 CloseDevice, -456 DoIO, -552 OpenLibrary,
-558 InitSemaphore, -564 ObtainSemaphore, -570 ReleaseSemaphore,
-624 CopyMem.
utility.library: -30 FindTagItem, -48 NextTagItem.
