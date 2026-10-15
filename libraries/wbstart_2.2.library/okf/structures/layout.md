---
file: layout
---
# wbstart 2.2 layout

File 4032B (0xfc0).  HUNK_HEADER @0: no resident names,
table 2 hunks {first 0, last 1}, sizes {0x3c7, 0xa} longs.
Hunk 0: CODE (0x3e9), 967 longs = 3868B body @0x24..0xf3f.
Hunk 1: DATA (0x3ea), hunk header says **1** long, body 4B of 0
@0xfb8 — but the hunk table allocates **0xa** longs (40B): the
extra 36 bytes are uninitialized globals (SAS/C slink artifact).

## hunk0 (CODE)

| off | contents |
|-----|----------|
| 0x000 | `moveq #0,d0 / rts` loader entry (returns 0) |
| 0x004 | "wbstart.library" |
| 0x014 | "$VER: wbstart.library 2.2 (18.9.96)\r\n" |
| 0x03a | "WBStart Handler" |
| 0x04a | "dos.library" |
| 0x056 | PACKED RomTag (26B): MatchTag->0x56, EndSkip->0x70, flags 0, ver 2, type 9, pri 0, name->0x04, id->0x14, init->0x0de |
| 0x070 | functab: 6 abs longs {198 1b0 1e6 26a 26a 2b8} + ffffffff |
| 0x08c | static CreateNewProc taglist for the handler (NP_Entry->0x3d0, NP_Name/NP_CommandName->0x3a, NP_Cli=1, zeros for CurrentDir/Priority/ConsoleTask/WindowPtr/HomeDir) + 0-terminator |
| 0x0de | initfn (rt_Init): exec>=39 gate, DATA+4=sysb, MakeLibrary(0x70,0,0,0x98,0), field fill, NewList(lib+116), InitSemaphore(lib+48), AddLibrary, DATA+0=lib |
| 0x198 | Open (-6) |
| 0x1b0 | Close (-12) |
| 0x1e6 | Expunge (-18) |
| 0x26a | reserved stub (-24/-30) |
| 0x26e | pktrt: PutMsg/WaitPort/GetMsg -> msg+10 |
| 0x2b8 | WBStart (-36) |
| 0x3d0 | handler process main (NP_Entry target) |
| 0x5ea | "utility.library" |
| 0x5fa | "icon.library" |
| 0x608 | CreatePool/DeletePool wrappers |
| 0x64c | AllocPooled(+4 header) / 0x676 FreePooled |
| 0x698 | name-or-path lock helper (dos Lock / dospath -54) |
| 0x6e4 | cli_CommandDir hijack: Cli(), dospath -78 dup, -36 free |
| 0x78a | "dospath.library" |
| 0x79c | client-process NP_ tag template (FreeSeglist/Input/Output/CloseInput/CloseOutput/Error/CloseError/CurrentDir/ConsoleTask/WindowPtr -> 0) |
| 0x7f4 | arg-copy helpers / launcher body 0xbe4 |
| 0xe32 | child-finished cleanup (UnLoadSeg + frees) |
| 0xeb4 | strlen, 0xec4 strcpy, 0xedc/0xee0 NewList, 0xef0 dos -498 |
| 0xf00 | dead stubs `moveq #0/1,rts` + nop/rts pads to 0xf1c |

## hunk1 (DATA, 40B alloc / 4B defined)

Globals, reached as a4@(x) with a4 = DATA+0x7ffe:

| off | contents |
|-----|----------|
| +0  | libbase (wbstart's own base; defined long = 0) |
| +4  | SysBase copy |
| +8  | DOSBase |
| +12 | IconBase |
| +16 | UtilityBase |
| +20 | memory pool (CreatePool -696) |
| +24 | dospath.library base |
| +28 | last dospath result copy |
| +32 | duplicated CLI path list |
| +36 | saved cli_CommandDir |

## reloc tail

CODE hunk: plain HUNK_RELOC32 (0x3ec), group0 ->hunk0 with
**non-sorted** offsets {5c 58 64 68 6c 70 74 78 80 7c 84 d0 a0
90 408}, group1 ->hunk1 {2be 1ec 1b6 19c e6 3d6} (the six
`lea DATA+0x7ffe,a4` small-data base loads).  HUNK_END,
then DATA hunk + END.  No symbol hunk.

## library extension (lib+0..151, dataSize 0x98)

| off | use |
|-----|-----|
| +34 | word: handler-running flag |
| +36 | seglist |
| +40 | handler process ptr |
| +44 | handler port-block (MsgPort-ish pooled block) |
| +48 | SignalSemaphore (40B) |
| +96 | embedded reply MsgPort (+111 sigbit, +112 sigtask, +116 list) |
| +132 | request/handshake message (+142 = caller taglist) |
| +150 | word 20 (set at init) |
