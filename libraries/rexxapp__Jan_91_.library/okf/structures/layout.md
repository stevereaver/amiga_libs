# Layouts

## Code hunk
- +0x00 `moveq#0,d0;rts` null stub
- +0x04 RomTag (flags=0, ver=0, NT_LIBRARY)
- +0x1e 14x `jmp abs` vector table (rt_EndSkip points here)
- +0x72 Library-image template passed to MakeLibrary(a1)
- +0x94 seglist slot / +0x98 SysBase slot (written by rt_Init)
- +0x9c rt_Init -> MakeLibrary(-396)
- +0xb6/+0xc4/+0xd6 Open/Close/Expunge
- +0xf8..+0x492 helpers, entry stubs, msg pump, port setup
- +0x4d8..+0x588 strings (packed, unaligned): "REXX",
  "Can't find rexxsyslib.library", "Rexx port not setup",
  "Too many Rexx msgs", "Can't find Rexx server",
  "No mem for Rexx msg", "Severe RETURN or EXIT",
  "(dissidents Jan 91) rexxapp.library"

## Context block (a5)
- +0 MsgPort: node +0..+13 (type=NT_MSGPORT), flags +14, sigbit +15,
  sigtask +16, msglist +20..+31
- +32 word: bit15 = shutdown flag; +33.b = outstanding msg count
- +34.l misc flag/ptr -> msg+112 on dispatch miss
- +38.l client command-handler fn
- +42.l rexxsyslib.library base (lazy-opened)
- +46.l,+50.l client fn ptrs (arg/result transforms, via `jsr a6@`)
- +54.l signal mask (1<<sigbit)
- +62 command table: pairs of [name-ptr? scanned inline] + handler
