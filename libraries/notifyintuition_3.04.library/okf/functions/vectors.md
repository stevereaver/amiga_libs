---
file: vectors
---
# Vectors (abs-long functab @h0+0x124, 7 entries)

-6  Open      h0+0xac4 — bsr 0x2c0: respawn subtask
              via CreateNewProc when lib+0x36 == 0;
              lib_OpenCnt(+0x20)++; returns a6 (lib).
              No flag handling (DELEXP gone in 3.04).
-12 Close     h0+0xad0 — OpenCnt--; returns 0.
              Shared with the fake screennotify lib
              (a6-relative — decrements whichever
              base is in a6).
-18 Expunge   h0+0xad8 — `moveq #0,d0; rts`.
              DEAD STUB: never expunges, no
              CloseLibrary/Remove/FreeMem path left.
-24 reserved  h0+0xad8 — same dead stub, returns 0.
-30 NotIStartNotify  h0+0xadc — a0=IntNotifyRequest.
              Locks public semaphore (FindSemaphore
              -594 of lib name + AttemptSemaphore -576,
              5 retries w/ Delay(5)) -> bsr 0xdb6 ->
              ReleaseSemaphore(-570) on lib+0x52.
              Errors -> inr_Error(+0x15), ret 0.
              Success: AllocVec(-684) 54B node,
              node+0x2e=req, node+0x32=ThisTask,
              InitSemaphore(-558), ln_Pri=inr_Pri
              (+0x16), pri-sorted Insert(-234) into
              lib+0x80, bsr 0xf18 (OR flags -> +0x4e,
              Signal(-324) subtask bit14), err=0,
              returns request.
              Checks at 0xdb6: +0x2c!=0 -> -4;
              flags==0 -> 102; target(+0x10)==0 -> 100;
              flags bit0|bit24 -> port class:
              target+8.ln_Type==4 else 100;
              flags bit1 -> signal class:
              inr_SignalNum(+0x14)!=0 else 101 and
              target type==13 (process) else 100;
              bit2/bit3 -> accepted (hook/other);
              none of 0/1/2/3/24 -> 99;
              (flags & 0x1ffc0)==0 -> 102;
              inr_UniqueID(+0x18) matching another
              task's node+0x18 -> 98 (same-task dup
              allowed); alloc fail -> 103. If
              inr_Name(+0x00) set: uppercases into a
              stack buf (0xec4), AllocVec(2*len)
              -> inr_Tokenstring(+0x04), dos
              ParsePattern(-840).
-36 NotIEndNotify    h0+0xb14 — a0=request. Same
              semaphore lock; Forbid(-132);
              inr_MsgCount(+0x28)!=0 -> -1;
              node(+0x2c)==0 -> Permit+ret 0;
              AttemptSemaphore(node) 5x Delay -> -2;
              Remove(-252) node, FreeVec(-690) node +
              Tokenstring, clears +0x2c/+0x04, bsr
              0xd36 rebuilds +0x4e from remaining
              requests + Signal subtask bit14;
              Permit; returns request.
              (-3 UNKNOWN path present but unreachable
              via the broken 0xd20 helper — see
              defects.md.)
-42 NotIFindUniqueTask h0+0xb48 — d0=UniqueID; scans
              lib+0x80 comparing node->req->+0x18;
              returns owning Task* (node+0x32) or 0.
              d0=0 -> 0. a0 ignored.

## Fake screennotify.library (base h0+0x180, NegSize 60/PosSize 38)

Built + Insert'd by initfn; vectors are 10
`jmp pc@(disp); nop` slots @h0+0x144..0x17a, all
redirecting into the main library's code.
fake+0x22 = real lib base (wrappers do
`moveal a6@(34),a5`).

-6  -> h0+0xac8: fake OpenCnt(+0x20)++, ret a6.
-12 -> h0+0xad0: OpenCnt--, ret 0 (shared code).
-18 -> h0+0xad8: dead stub, ret 0.
-24 -> h0+0xad8: dead stub, ret 0.
-30 -> h0+0xb72: named start. a0=screen name,
      a1=MsgPort (required, else ret 0), d0=pri.
      AllocVec 48B req; req+0x10=port,
      req+0x16=pri; screen name -> FindPubScreen-ish
      (int -522 LockPubScreenList / MatchPattern /
      -528 UnlockPubScreenList) -> req+0x00;
      flags=0x01800110; calls real -30.
-36 -> h0+0xc58: shared end (see below).
-42 -> h0+0xbc4: anonymous start. a0=MsgPort
      (required), d0=pri; same 48B req, no name;
      flags=0x01800400; calls real -30.
-48 -> h0+0xc58: shared end.
-54 -> h0+0xc0a: Workbench start. a0=MsgPort,
      d0=pri; req+0x00="Workbench" @h0+0xa2;
      flags=0x0180c010; calls real -30.
-60 -> h0+0xc58: shared end.

sn end (h0+0xc58): calls real -36 on the real lib;
while req+0x2c still set, drains the request's port
(GetMsg -372 / ReplyMsg -378 loop) and retries;
then FreeVec(req) (the lib-owned 48B request);
returns 1. sn -30/-42/-54 requests are allocated
by the wrapper and freed by the end call, unlike
main -30 where the caller owns the request.

## Subtask (entry h0+0x33c via CreateNewProc taglist built @0x2d6, runs under lib name)

a5=lib via h0+0x120 cell; lib+0x36=ThisTask; two
CreateMsgPort(-666) -> +0x3a/+0x3e; wait mask
0xc000|mp_SigBits -> +0x46; InitSemaphore(-558) on
lib+0x52 named like the library; AddSemaphore(-600);
Wait(-318) loop on +0x46 — bit15 shutdown, bit14
notify-scan (walks request nodes under
AttemptSemaphore, dispatches per event bits via the
word-offset jump table @h0+0x5e8 — PutMsg/Signal/
hook jsr, WaitPort/GetMsg on WAIT_REPLY, in-flight
tracking list at lib+0x8e via AddTail -240 of 14B
nodes), repatch pass (h0+0x1480), command-port
drain (spawns " notify_subtask " process per msg
via CreateNewProc). Shutdown: RemSemaphore(-606),
ReleaseSemaphore(-570), DeleteMsgPort(-672) x2,
+0x36=0.

## IntNotifyRequest (48B, user-allocated)

+0x00 inr_Name (pattern, optional); +0x04
inr_Tokenstring (lib-filled); +0x08 inr_UserData;
+0x0c inr_Flags (0=msg,1=signal,2=hook,3=hook2,
4=WAIT_REPLY,5=NOTIFY_INITIAL,6..16 events,23+24
screennotify class bits — bit24 also acts as port
delivery alias, bit4 seen set in sn requests but
filtered out by the 0x1ffc0 mask); +0x10
inr_Task/inr_Port/inr_Hook (type-checked); +0x14
inr_SignalNum; +0x15 inr_Error; +0x16 inr_Pri;
+0x18 inr_UniqueID; +0x28 inr_MsgCount; +0x2c
inr_ReqSemaphore (lib-set node).

## External calls observed

exec: -132 Forbid -138 Permit -234 Insert -240
AddTail -252 Remove -276 FindName -294 FindTask
-300 SetTaskPri -318 Wait -324 Signal -366 PutMsg
-372 GetMsg -378 ReplyMsg -384 WaitPort
-420 SetFunction -552 OpenLibrary
-558 InitSemaphore -564 ObtainSemaphore -570
ReleaseSemaphore -576 AttemptSemaphore -594
FindSemaphore -600 AddSemaphore -606 RemSemaphore
-624 CopyMem -636 CacheClearU -666 CreateMsgPort
-672 DeleteMsgPort -678 ObtainSemaphoreShared
-684 AllocVec -690 FreeVec -720
AttemptSemaphoreShared.
dos: -198 Delay -498 CreateNewProc -840 ParsePattern
-846 MatchPattern.
intuition: -414 LockIBase -420 UnlockIBase -510
LockPubScreen -516 PubScreenStatus -522
LockPubScreenList -528 UnlockPubScreenList.
utility: -36 GetTagData.
self: `jsr a6@(-30)` x3 — the fake screennotify
start wrappers call the real library's -30 vector
on the real base.
