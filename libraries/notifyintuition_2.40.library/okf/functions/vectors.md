---
file: vectors
---
# Vectors (abs-long functab @h0+0x118, 7 entries)

-6  Open      h0+0x93a — lib_OpenCnt(+0x20)++;
              bclr #3 lib_Flags (clears LIBF_DELEXP);
              respawns subtask via CreateNewProc when
              lib+0x36 == 0 (helper h0+0x1ec/0x202);
              returns a6 (lib base).
-12 Close     h0+0x94c — OpenCnt--; on 0 sets
              LIBF_DELEXP (bit3 flags+0xe); returns 0.
-18 Expunge   h0+0x95c — refuses (ret 0) while
              OpenCnt!=0, request list +0x80 non-empty,
              outstanding msgs +0x4a !=0, or DELEXP not
              already latched (bset #3,+0xe tests old
              value: a live lib answers 0 once, a
              closed/failed one proceeds). Up to 20x:
              Signal(subtask,1<<15) + dos Delay(5) until
              +0x36 cleared (helper h0+0xb4e only Delays
              when ThisTask.ln_Type==NT_PROCESS=13).
              Then CloseLibrary(-414) dos/intuition/
              utility, Remove(-252) if linked,
              FreeMem(-210) lib; returns seglist.
-24 reserved  h0+0x9e8 — returns 0.
-30 NotIStartNotify  h0+0x9ec — a0=IntNotifyRequest.
              Locks the public semaphore (FindSemaphore
              -594 of lib name, AttemptSemaphore -576,
              5 retries with Delay via h0+0xb72). Returns
              0 with inr_Error(+0x15) set; on success
              allocates + InitSemaphores a 54B node,
              copies inr_Pri(+0x16) to ln_Pri, Insert(-234)
              into +0x80 sorted, ORs flags into +0x4e,
              Signal(-324)(subtask,1<<14), clears
              inr_Error, returns the request pointer.
              Checks: inr_ReqSemaphore(+0x2c)!=0 -> -4;
              inr_Flags==0 -> 102; inr_Task/Port/Hook
              (+0x10)==0 -> 100; INRF_SEND_MESSAGE bit0
              requires +0x10.ln_Type==4 (MsgPort) else
              100; INRF_SEND_SIGNAL bit1 requires
              inr_SignalNum(+0x14)!=0 (else 101) and
              +0x10.ln_Type==13 (Process) else 100;
              none of bits0/1/2 -> 99; no event bits
              (flags&~0x3f)==0 -> 102; inr_UniqueID
              (+0x18) matching another task's request ->
              98; alloc failures -> 103. If inr_Name set:
              uppercases into stack buf (h0+0xca0),
              allocates 2*len token buf -> inr_Tokenstring
              (+0x4), runs dos ParsePattern(-840).
-36 NotIEndNotify    h0+0xa24 — a0=request. Same
              semaphore lock; Forbid(-132); inr_MsgCount
              (+0x28)!=0 -> -1; node(+0x2c)==0 -> plain
              Permit+0. AttemptSemaphore(node) with 5
              Delay retries -> -2; then Remove(-252),
              FreeVec(-690) node + Tokenstring, clears
              +0x2c/+0x4, rebuilds +0x4e (helper h0+0xb1e)
              and Signals subtask bit14; Permit; returns
              request.
-42 NotIFindUniqueTask h0+0xa58 — d0=UniqueID; scans
              +0x80 list comparing node->req->+0x18;
              returns the owning Task* (node+0x32) or 0.
              d0=0 -> 0.

## Subtask (entry h0+0x27a, runs under lib name)

a5=lib via h0+0x114 cell; lib+0x36=ThisTask; two
CreateMsgPort(-666) -> +0x3a/+0x3e (+0xb4); wait mask
0xc000|mp_SigBits -> +0x46; InitSemaphore(-558) on
lib+0x52 named like the library; AddSemaphore(-600);
Wait(-318) loop on +0x46 — bit15 shutdown, bit14
notify-scan (h0+0x60a walks request nodes with
AttemptSemaphore'd locks, clears seen bit5, dispatches
per remaining event bits via h0+0x66a delivering
IntNotifyMessage class 0x43210000 by PutMsg(-366) /
direct Signal(-324) by inr_SignalNum / hook jsr for
INRF_USE_HOOK, WaitPort/GetMsg on WAIT_REPLY),
repatch pass (h0+0x111e), then drains the command port
(h0+0x35a spawns a " notify_subtask " process per msg
via CreateNewProc) and the reply port (h0+0x3ca frees
returned msgs). Shutdown: RemSemaphore(-606),
ReleaseSemaphore(-570), DeleteMsgPort(-672) x2,
+0x36=0.

## IntNotifyRequest (48B, user-allocated)

+0x00 inr_Name (pattern, optional); +0x04
inr_Tokenstring (lib-filled); +0x08 inr_UserData;
+0x0c inr_Flags (INRF_*: 0=msg,1=signal,2=hook,4=
WAIT_REPLY,5=NOTIFY_INITIAL,6..18 events,23=
NOT_MYOWNREQUEST,24..31 lib-reserved); +0x10
inr_Task/inr_Port/inr_Hook (delivery target, type-
checked); +0x14 inr_SignalNum; +0x15 inr_Error;
+0x16 inr_Pri; +0x18 inr_UniqueID; +0x28 inr_MsgCount;
+0x2c inr_ReqSemaphore (lib-set node).

## External calls observed

exec: -132 Forbid -138 Permit -198 AllocMem -210 FreeMem
-234 Insert -252 Remove -276 FindName -294 FindTask
-300 SetTaskPri -318 Wait -324 Signal -366 PutMsg
-372 GetMsg -378 ReplyMsg -384 WaitPort -414 CloseLibrary
-420 SetFunction -552 OpenLibrary -558 InitSemaphore
-564 ObtainSemaphore -570 ReleaseSemaphore
-576 AttemptSemaphore -594 FindSemaphore -600 AddSemaphore
-606 RemSemaphore -624 CopyMem -636 CacheClearU
-666 CreateMsgPort -672 DeleteMsgPort -678
ObtainSemaphoreShared -690 FreeVec -720
AttemptSemaphoreShared.
dos: -198 Delay -498 CreateNewProc -840 ParsePattern
-846 MatchPattern. intuition: -414 LockIBase
-420 UnlockIBase -522 LockPubScreenList
-528 UnlockPubScreenList (-96 DisplayBeep-era vectors
only reached via the patch table). utility: -36
GetTagData.
