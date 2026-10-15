# muispecial.library structures

## File layout

```
HUNK_HEADER: names=0, hunks=2, first=0, last=1, sizes={0x2bc,0x16}
hunk0: HUNK_CODE, 700 LW = 2800 B
  RELOC32: {14 -> h0, descending: 0x9a4..0x988 functab, 0x100 lea,
            0x72/0x6e/0x6a/0x62/0x5e romtag fields}
           {9 -> h1: lea.l $0.l,a4 sites 0x878..0x278}
  HUNK_END
hunk1: HUNK_DATA, 22 LW = 88 B
  HUNK_END
```

## RomTag (hunk0+0x5c)

```
4afc 0000005c 00000076 00 13 09 00 00000004 0000001d 000000f4
matchword  matchtag  endskip  flags ver=19 type pri name  idstr   init
```

- flags=0x00 → **non-AUTOINIT**; rt_Init = direct function @0xf4.
- rt_Name → 0x04 (`muispecial.library`), rt_IdString → 0x1d (inside
  the $VER string: `muispecial.library 19.11 (12.02.97) ©1992-1997
  Stefan Stuntz\r\n`).

## initfn (0xf4) — manual library construction

```
MakeLibrary(functab@0x988, initstruct=0, initfn=0, dsize=0x54, seg=0)
lib->ln_Type = 9 (NT_LIBRARY), ln_Pri = 0
lib->ln_Name = _name, lib_Flags = 6 (LIBF_SUMUSED|LIBF_CHANGED)
lib->lib_Version = 19, lib_Revision = 11
lib->lib_IdString = _idstr ($VER string)
lib+0x22 = a0 (seglist, saved by InitResident)
InitSemaphore(lib+0x26)          ; open/close guard semaphore
_initdeps()                      ; gd+0=SysBase, InitSemaphore(gd+0x20)
success -> AddLibrary(lib), return lib
fail    -> FreeMem(lib-negsize, negsize+0x54), return 0
```

## gd (hunk1, 88 B)

```
+0x00 ExecBase          +0x04 UtilityBase     +0x08 DOSBase
+0x0c GfxBase           +0x10 process task    +0x14 data buffer
+0x18 waveform table    {01 08 09 02 04 06 00 00}
+0x1e busy flag (word)  +0x20 SignalSemaphore (36 B)
+0x4e,+0x52             mti.data header longs
```

## Audio I/O

- IOAudio reqs are 68 B; ioa_Data points at gd+0x18 / gd+0x1b
  waveforms or gd+0x14+0x1b6c (payload inside mti.data).
- Channels written to AUD0VOL-AUD3VOL ($dff0a8/$b8/$c8/$d8).
- Timer req 40 B, io_Command 9 (TR_ADDREQUEST), period computed by
  `_dotone` via `_divs`/`_divu32` (d0 ticks = rate-derived).
- Audio ioreq io_Command = 3 (CMD_WRITE/ADCMD).
