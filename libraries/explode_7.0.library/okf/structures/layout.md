# explode.library 7.0 layout

## File

- 1 code hunk (0x1A1 longs = 0x684 bytes).
- RomTag @4: AUTOINIT, rt_Version 7, NT_LIBRARY pri 0; endskip 0x682.

## Hunk map (original)

| Off | Contents |
|----:|----------|
| 0x000 | `moveq #-1,d0;rts` pre-tag stub |
| 0x004 | Resident tag |
| 0x01e | "explode.library" |
| 0x02e | idstr "explode.library 7.0 (28.08.96) written by P.Struijk & A.J.Brouwer, 68040/60 bugfix by Grzegorz Calkowski\r\n" |
| 0x099 | "dos.library" |
| 0x0a6 | INIT: datasize=0x36, functab=0xB6, datatab=0xD2, initfunc=0xFE |
| 0x0b6 | LONG functab (6 + term) |
| 0x0d2 | datatab — E0/C0/D0 InitStruct form |
| 0x0fe | LibInit (dual wedge install) |
| 0x166 | LibOpen |
| 0x174 | LibClose -> expunge body @0x186 |
| 0x182 | ret0 stub (vectors -18,-24) |
| 0x186 | expunge body (unpatch both vectors, Remove/CloseLibrary/FreeMem) |
| 0x1ea | -36 mark (`bset #3,+34`) |
| 0x1f2 | `ExpStubNL` — NewLoadSeg stub `jsr $0;bra +6` |
| 0x1fa | `ExpStub` — LoadSeg stub `jsr $0;` falls into check |
| 0x200 | shared signature check + inflate call + CacheClearU |
| 0x288 | -30 Explode trampoline |
| 0x2b2 | decoder setup + outer loop (inlined hunk-walks) |
| 0x426 | movem-burst block copy |
| 0x468 | ring-wrap/decoder-refill coroutine (LAB_0033) |
| 0x5c2 | surplus-hunk FreeMem tail (inlined walks) |
| 0x60a | tab1 (12B: class bases/bits) |
| 0x616 | tab2 (9 x 12B records, indexed by header lo-nibble) |
| 0x682 | endskip |

## Datatab (hunk+0xd2)

```
byte @8  = 9            ln_Type = NT_LIBRARY
long @10 = &name        ln_Name
byte @14 = 6            lib_Flags
word @20 = 6            lib_Version   <-- NOTE: 6, not 7!
word @22 = 0            lib_Revision
long @24 = &idstr       lib_IdString
```

`rt_Version` = 7 and the idstring says "7.0", but the node is
initialised with version 6 revision 0 — a shipped inconsistency.

## Decoder work frame (a4, 54 bytes on stack)

| Off | Field |
|----:|-------|
| +0  | literal-run remaining (w) |
| +2  | bit buffer (b) |
| +3  | resume-with-match-len flag/len (b) |
| +4  | block counter (l; sign bit = "1<<len minus 1" mode) |
| +8  | tab1 copy: 4B distance-class bases |
| +12 | tab1b copy: 8B distance-class bit counts (last byte = hi nibble) |
| +20 | lensums: 8 words = 1<<len per class |
| +28 | prefix sums of first 4 lensum words |
| +36 | tab2 record copy: 12B extra-distance-bits per class/level |
| +48 | saved seg base (hunk0 link field addr) |
| +52 | last hunk index -1 (output hunk limit) |

## Packed-segment conventions

- a5 = control block at `seg_hunk0 + 32`; marker string at its +8.
- Bit stream stored backwards, ending inside hunk[count-2].
- Ring = last hunk's data area; output written forward from each
  hunk's data start; surplus tail hunks are FreeMem'd afterward.
- Relocation fixups are interleaved in the control stream (delta
  offsets accumulated in d2, hunk base added into `*(a3+off)`).
