---
file: layout
---
# notifyintuition 3.04 layout

File 5796B (0x16a4). Single CODE hunk.

## Hunk map

- 0x00 HUNK_HEADER 0x3f3: no resident names, table 1,
  first=last=0, hunk0 = 0x58b longs (5676B).
- 0x1c HUNK_CODE 0x3e9, body 0x58b longs @0x20..0x164c
  (declared==physical).
- 0x164c RELOC32 0x3ec, hunk0, 17 offsets:
  0x06/0x0a/0x12/0x16/0x1a = RomTag matchtag/endskip/
  name/idstr/init; 0xf4/0xf8/0xfc = InitTable
  functab/datatab/initfn; 0x106/0x118 = name/idstr
  pointers embedded in the InitStruct stream;
  0x124..0x13c = 7 functab entries.
- 0x169c terminator, 0x16a0 HUNK_END 0x3f2.

## h0 head

- +0x00 `moveq #-1,d0; rts` — load-point stub.
- +0x04 RomTag: rt_MatchTag->+4, rt_EndSkip->+0xd6,
  flags 0x80 (RTF_AUTOINIT), rt_Version 3,
  rt_Type 9 (NT_LIBRARY), rt_Pri 0,
  rt_Name->+0x1e, rt_IdString->+0x3c, rt_Init->+0xf0.

## Strings

- +0x1e "notifyintuition.library" — also task name,
  public semaphore name and the FindTask double-load
  guard; the "intuition.library" suffix at +0x26 is
  reused by initfn's OpenLibrary call (overlapping
  string quirk).
- +0x36 "$VER: " prefix + id body: the RomTag id
  points INSIDE it at +0x3c — "notifyintuition"
  + 0xa0 NBSP separators + "3.04\xa0(26.10.97)\xa0
  \xa9\xa0by\xa0H.-W.\xa0Schober\r\n" (0xa9 = (c)).
  One string serves both $VER and idstring.
- +0x71 "screennotify.library" — name of the
  embedded fake library (new in 3.04).
- +0x86 "dos.library", +0x92 "utility.library",
  +0xa2 "Workbench" (hardcoded name for the
  screennotify -54 vector / pubscreen matching).
- +0xac 0xab" notify_subtask "0xbb — NP_Name of
  client notification processes spawned by the
  subtask.
- +0xbf 0xab" notify_int Patches "0xbb — name of
  the patch-context public semaphore (copied to
  ctx+0x120).
- +0xd0 13-word table 1<<0 .. 1<<12 + pad — signal-
  bit index to mask, used by the subtask.

## InitTable @h0+0xf0

- dataSize 0x9c (private data spans lib+0x22..0x9b —
  SHRUNK from 2.41's 0xc0: layout reorganised,
  second MinList at +0x8e)
- funcTab -> h0+0x124, absolute longs, -1 terminated
- dataTab -> h0+0x100 (InitStruct stream)
- initFn  -> h0+0x1a6

## InitStruct stream @h0+0x100

`a0 0c 09 00` byte 9 -> lib+0x0c (dead: inside
ln_Name, overwritten next); `80 0a <0000001e>`
ln_Name -> +0x1e; `a0 0e 06 00` lib_Flags = 6
(LIBF_SUMUSED|LIBF_CHANGED); `90 14 0003`
lib_Version = 3; `90 16 0003` lib_Revision = 3;
`80 18 <0000003c>` lib_IdString -> +0x3c; `00` end.
Byte-identical stream to 2.41 except the rev words.

## initfn @h0+0x1a6

Stores lib base at h0+0x120 (self cell in the pad
gap before the functab, read by the subtask entry
and patch/fake-lib wrappers), seglist -> lib+0x22,
exec -> lib+0x26. FindTask(-294)("notifyintuition
.library") -> init fails (returns 0) if a task of
that name already exists. OpenLibrary(-552) x3 ->
lib+0x2a/2e/32 (dos/intuition/utility, ver 0).
NewList lib+0x8e then lib+0x80 (helper 0x20a/
0x216). Spawns the notify subtask via
CreateNewProc(-498, dos) on a stack-built taglist:
NP_Entry=h0+0x33c, NP_CurrentDir=0,
NP_StackSize=0x1000, NP_Name=name string,
NP_Priority=5, NP_WindowPtr/NP_HomeDir/
NP_CopyVars=0. Then bsr 0x258:

## Fake screennotify.library build @0x258

a2 = h0+0x180 (in-place, inside the code hunk):
ln_Type=9, lib_Version=2, lib_Revision=0,
lib_IdString->+0x3c (borrows notify's id),
lib_NegSize=60 (10 vectors), lib_PosSize=38,
ln_Name->+0x71 "screennotify.library",
fake+0x22 = real lib base. Forbid; FindName(-276)
on exec LibList (+0x17a) — if no screennotify
library is already resident, Insert(-234) it
sorted by ln_Pri (0); Permit. Runtime base seen
at 0x40180 (reloc-free: hunk body IS the struct).
Vectors: 10 `jmp pc@(disp); nop` slots
@h0+0x144..0x17a (see vectors.md).

## Library private area (base offsets, dataSize 0x9c)

+0x22 seglist, +0x26 ExecBase, +0x2a DOSBase,
+0x2e IntuitionBase, +0x32 UtilityBase,
+0x36 notify-subtask Task* (0 until spawned),
+0x3a command MsgPort*, +0x3e reply MsgPort*,
+0x42 patch-context block ptr,
+0x46 Wait() mask (0xc000|sigbits),
+0x4a outstanding notification messages,
+0x4e aggregate event mask (OR of all inr_Flags),
+0x52 public SignalSemaphore "notifyintuition
.library" (46B -> +0x7f),
+0x80 MinList of request nodes (pri-sorted),
+0x8e MinList of in-flight reply trackers
(14B AllocVec nodes, key at node+0x0a, AddTail'd
by the subtask reply machinery).

## Request node (54B AllocVec incl. 4B size prefix)

struct SignalSemaphore (46B, InitSemaphore'd, used
as per-request lock) + node+0x2e = IntNotifyRequest*,
node+0x32 = owner Task* (ThisTask at register time).

## Patch-context block (311B, lib+0x42)

Same scheme as 2.41: FindSemaphore(-594) of
" notify_int Patches "; if absent AllocVec(311),
CopyMem(-624) 144B trampoline template from
h0+0x159c -> ctx+0x90, InitSemaphore(ctx), name
-> ctx+0x120, ln_Pri=1 @ctx+0x2e,
AddSemaphore(-600); then ObtainSemaphoreShared
(-678). Trampolines are the same self-locating
`moveal pc@/movel pc@/subal/jmp aX@(0,dX:l)`
pattern; SetFunction installs ctx+stuboff as the
new intuition vector.

## Patch record table @h0+0x1522 (10B recs, w0<0 = end)

{bit, lvo, ctxslot, handler rel to 0x1522, stuboff}:

```
bit15 CloseWorkBench    -78   0x30 h0+0x1056 ctx+0x90
bit14 OpenWorkBench    -210   0x38 h0+0x10ae ctx+0x9e
bit10 PubScreenStatus  -552   0x40 h0+0x111c ctx+0xac
bit13 CloseWindow       -72   0x48 h0+0x114e ctx+0xba
bit12 OpenWindow       -204   0x50 h0+0x1184 ctx+0xc8
bit11 OpenWindowTagList-606   0x58 h0+0x1244 ctx+0xd6
bit8  CloseScreen       -66   0x60 h0+0x1282 ctx+0xdc
bit7  OpenScreen       -198   0x68 h0+0x12a8 ctx+0xea
bit6  OpenScreenTagList-612   0x70 h0+0x12f6 ctx+0xf8
bit16 LockPubScreen    -510   0x78 h0+0x1334 ctx+0xfe
bit17 ScreenToFront    -252   0x80 h0+0x1366 ctx+0x104
bit18 ScreenToBack     -246   0x88 h0+0x138a ctx+0x112
```

Installer h0+0x1480 (Forbid; forces bit11|12
together |=0x1800 and bit6|7 together |=0xc0;
SetFunction per record or restore; CacheClearU
-636). Remover h0+0x1454 restores ctx[slot+4].
Same 12 records as 2.41, shifted to 0x1522.

## Delta vs 2.41

- File 5796B vs 4988B (+808B); body 0x162c vs
  0x1304. Version 3 rev 3, date "12.7.96"->
  "26.10.97".
- dataSize 0xc0 -> 0x9c: private area reorganised;
  +0x8e second MinList (in-flight replies); the
  2.41 +0xb4 reply-port dup and unused tail gone.
- NEW: fake screennotify.library (vectors
  @h0+0x144, struct @h0+0x180, name @+0x71),
  registered at init.
- Expunge removed: -18 and -24 share a
  `moveq #0,rts` stub; Close no longer latches
  LIBF_DELEXP; all expunge code (CloseLibrary x3/
  Remove/FreeMem/signal-wait loop) deleted.
- Requests now AllocVec'd (54B node, 48B sn
  request, 14B reply trackers); 2.41 mixed
  AllocMem/FreeVec.
- -30 accepts flag bit24 as a port-delivery alias
  (screennotify requests use bits 23/24) and the
  event mask is flags & 0x1ffc0 (bits 6..16).
- Dispatcher still a pc-indexed jump table
  (word offsets @h0+0x5e8); subtask/sub-command
  machinery reworked around the +0x8e list.
