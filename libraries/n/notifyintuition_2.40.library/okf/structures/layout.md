---
file: layout
---
# notifyintuition 2.40 layout

File 4928B (0x1340). Single CODE hunk.

## Hunk map

- 0x00 HUNK_HEADER 0x3f3: no resident names, table 1,
  first=last=0, hunk0 = 0x4b2 longs (4808B).
- 0x18 HUNK_CODE 0x3e9, body 0x4b2 longs @0x20..0x12e8
  (declared==physical).
- 0x12e8 RELOC32 0x3ec, hunk0, 17 offsets:
  0x06/0x0a/0x12/0x16/0x1a = RomTag matchtag/endskip/
  name/idstr/init; 0xe8/0xec/0xf0 = InitTable
  functab/datatab/initfn; 0xfa/0x10c = name/idstr
  pointers embedded in the InitStruct stream;
  0x118..0x130 = 7 functab entries.
- 0x1338 terminator, 0x133c HUNK_END 0x3f2.

## h0 head

- +0x00 `moveq #-1,d0; rts` — load-point stub.
- +0x04 RomTag: rt_MatchTag->+4, rt_EndSkip->+0xca,
  flags 0x80 (RTF_AUTOINIT), rt_Version 2,
  rt_Type 9 (NT_LIBRARY), rt_Pri 0,
  rt_Name->+0x1e, rt_IdString->+0x3c, rt_Init->+0xe4.

## Strings

- +0x1e "notifyintuition.library" — also task name and
  public semaphore name; the "intuition.library" suffix
  at +0x24 is reused by initfn's OpenLibrary call
  (overlapping string quirk).
- +0x36 "$VER: notifyintuition.library 2.40 (01.06.96)
   by H.-W. Schober" (unreferenced copy).
- +0x3c id string = same text without "$VER: " and with
  0xa0 NBSP separators + 0xa9 (c): "notifyintuition
  .library\xa02.40\xa0(01.06.96)\xa0\xa9\xa0by\xa0H.-W.
  \xa0Schober\r\n".
- +0x79 "dos.library", +0x85 "utility.library",
  +0x95 "Workbench" (passed to intuition LockIBase-era
  pubscreen lookup).
- +0xa0 0xab" notify_subtask "0xbb — NP_Name of client
  notification processes spawned by the subtask.
- +0xb2 0xab" notify_int Patches "0xbb — name of the
  patch-context public semaphore (copied to ctx+0x120).
- +0xca 13-word table 1<<0 .. 1<<12 (signal-bit index to
  mask, used by the subtask dispatcher h0+0x4b8).

## InitTable @h0+0xe4

- dataSize 0xbc (private data spans lib+0x22..0xbb)
- funcTab -> h0+0x118, absolute longs, -1 terminated
- dataTab -> h0+0xf4 (InitStruct stream)
- initFn  -> h0+0x138

## InitStruct stream @h0+0xf4

`a0 0c 09` byte 9 -> lib+0x0c (dead: inside ln_Name,
overwritten next); `80 0a <0000001e>` ln_Name -> +0x1e;
`a0 0e 06` lib_Flags = 6 (LIBF_SUMUSED|LIBF_CHANGED);
`90 14 0002` lib_Version = 2; `90 16 0028`
lib_Revision = 40; `80 18 <0000003c>` lib_IdString ->
+0x3c; `00` end.

## initfn @h0+0x138

Stores lib base at h0+0x114 (self cell read by the
subtask and every patch wrapper), seglist -> lib+0x22,
exec -> lib+0x26. FindTask(-294)("notifyintuition
.library") -> init fails (returns 0) if a task of that
name already exists. OpenLibrary(-552) x3 ->
lib+0x2a/2e/32 (dos/intuition/utility, ver 0). Empty
MinList init at lib+0x80 (hand-rolled NewList, h0+0x196).
Spawns the notify subtask (entry h0+0x27a) via
CreateNewProc on a stack-built taglist:
NP_Entry(0x800003eb)=h0+0x27a, NP_CurrentDir=0,
NP_StackSize=0x1000, NP_Name=name string,
NP_Priority=5, NP_WindowPtr=0, NP_HomeDir=0,
NP_CopyVars=0, TAG_DONE. Returns lib or 0.

## Library private area (base offsets)

+0x22 seglist, +0x26 ExecBase, +0x2a DOSBase,
+0x2e IntuitionBase, +0x32 UtilityBase,
+0x36 notify-subtask Task* (0 until spawned; cleared by
subtask shutdown -> releases expunge),
+0x3a command MsgPort* (to subtask), +0x3e reply
MsgPort* (dup at +0xb4), +0x42 patch-context block ptr,
+0x46 Wait() mask (0xc000|sigbit(port1)|sigbit(port2)),
+0x4a outstanding notification messages,
+0x4e aggregate event mask (OR of all inr_Flags),
+0x52 public SignalSemaphore "notifyintuition.library",
+0x80 MinList of request nodes (pri-sorted via Insert).

## Request node (54B, allocated per StartNotify)

struct SignalSemaphore (46B, InitSemaphore'd, used as
the per-request lock) + node+0x2e = IntNotifyRequest*,
node+0x32 = owner Task*.

## Patch-context block (311B, lib+0x42)

Created lazily by subtask h0+0x107c: doubles as public
SignalSemaphore " notify_int Patches " (name copied to
ctx+0x120, ln_Pri=1 at ctx+0x2e). ctx+0x90..+0x120 hold
a 144B template copied from h0+0x1238 — twelve tiny
self-locating trampolines (`moveal pc@,aX; movel pc@,dX;
subal aX,dX; jmp aX@(0,dX:l)`); SetFunction installs
ctx+stuboff as the new intuition vector so ctx[slot]/[slot+4]
keep {orig,current handler} pairs switchable at runtime.

## Patch record table @h0+0x11be (10B recs, w0<0 = end)

{bit, lvo, ctxslot, handler rel to 0x11be, stuboff}:

```
bit15 CloseWorkBench    -78   0x30 h0+0xdde  ctx+0x90
bit14 OpenWorkBench    -210   0x38 h0+0xe14  ctx+0x9e
bit10 PubScreenStatus  -552   0x40 h0+0xe70  ctx+0xac
bit13 CloseWindow       -72   0x48 h0+0xe96  ctx+0xba
bit12 OpenWindow       -204   0x50 h0+0xec8  ctx+0xc8
bit11 OpenWindowTagList-606   0x58 h0+0xf08  ctx+0xd6
bit8  CloseScreen       -66   0x60 h0+0xf42  ctx+0xdc
bit7  OpenScreen       -198   0x68 h0+0xf64  ctx+0xea
bit6  OpenScreenTagList-612   0x70 h0+0xfa4  ctx+0xf8
bit16 LockPubScreen    -510   0x78 h0+0xfde  ctx+0xfe
bit17 ScreenToFront    -252   0x80 h0+0x100c ctx+0x104
bit18 ScreenToBack     -246   0x88 h0+0x102c ctx+0x112
```

Installer h0+0x111e (Forbid, ObtainSemaphoreShared ctx):
bits 11|12 force-enable each other (|=0x1800), as do
6|7 (|=0xc0); for each record either patches
(SetFunction intuition/lvo/ctx+stub, saves orig) or
restores ctx[slot+4]=orig when the mask bit is clear;
CacheClearU(-636) afterwards. Bits match
INRF_BEFORE/AFTER_* flag bits of inr_Flags.
