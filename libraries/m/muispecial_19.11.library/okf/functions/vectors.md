# muispecial.library vectors

Functab at hunk0+0x988, eight entries + `ffffffff` terminator.
All entries are absolute-long mode (MakeLibrary builds `jmp abs.l`
stubs). Library calls receive `a6 = libbase`; internal helpers take
`a4 = _gd` (data hunk base) loaded via `lea.l $0.l,a4`.

## Standard vectors

| LVO | entry | behaviour |
|-----|-------|-----------|
| -6  | _open (0x1e4)  | opencnt++, clear LIBF_DELEXP, ObtainSemaphore(lib+0x26), on first open lazily OpenLibrary dos/graphics/utility v37 into gd+8/+0xc/+4 (all three required or open fails), ReleaseSemaphore; returns libbase or 0 |
| -12 | _close (0x228) | ObtainSemaphore, `_stub382` (empty no-op), ReleaseSemaphore, opencnt--; if 0 and DELEXP -> expunge (returns seglist) |
| -18 | _expunge (0x186) | if opencnt!=0 or gd+0x10 (process) or _closedeps fails: set LIBF_DELEXP, return 0; else Remove, FreeMem(lib-negsize, total), return seglist @lib+0x22 |
| -24 | _v24 (0x000) | `moveq #0,d0; rts` reserved stub |

## Library vectors

| LVO | entry | behaviour |
|-----|-------|-----------|
| -30 | _v30 (0x398) | stub: loads a4=_gd, returns 0 |
| -36 | _v36 (0x3b0) | stub: loads a4=_gd, returns 0 |
| -42 | _v42 (0x3c4) | stub: saves d0-d2/a0 to stack (unused), returns d0 unchanged |
| -48 | _v48 (0x872) | **MUISpecial_Start** — the only real API: semaphore gd+0x20 guarded; refuses if busy(gd+0x1e) or process live(gd+0x10); requires AvailMem>0x493e0; finds + reads `mti.data` (magic header check), AllocVecs payload, CreateNewProc "MUI-Audio-Process" with entry=_audioproc; returns nonzero-ish d0 on success |

## Internal functions

- `_initdeps` (0x26c): gd+0=SysBase, InitSemaphore(gd+0x20)
- `_closedeps` (0x296): refuses if gd+0x10 set; FreeVec gd+0x14,
  CloseLibrary utility/graphics/dos (gd+4,+0xc,+8), clears fields
- `_opendeps` (0x30a): lazy OpenLibrary of the three deps
- `_allocreq` (0x3de): CreateMsgPort + `_allocioreq`
- `_freereq` (0x412): frees ioreq + its reply port
- `_opentimer` (0x43a): OpenDevice timer.device into a 40B ioreq
- `_closedev` (0x470): CloseDevice + free
- `_openaudio` (0x494): 68B ioreq, ioa_Data=waveform ptr, OpenDevice
  audio.device unit 3
- `_closeaudio` (0x4ea): CloseDevice + free
- `_dotone` (0x510): timer delay — period math via `_divs`, BeginIO +
  WaitIO on the timer ioreq
- `_audioproc` (0x588): process entry — opens 2 audio channels + timer,
  writes AUD0-3VOL ($dff0a8-b8-c8-d8) = 0x5c, loops 92× BeginIO/WaitIO
  polling Signal for break bits 12-13; AbortIO + cleanup on exit;
  Forbid, clears gd+0x10
- `_finddata` (0x79e): Open `mui:docs/mti.data` else `s:mti.data`;
  fallback scans s: via Lock/Examine/ExNext for a file with
  fib_Size == 0x15a09 (88585)
- `_allocioreq` (0x9ac): AllocMem(size,0x10001), sets NT_REPLYMSG,
  io_Length, reply port
- `_freeioreq` (0x9ee): FreeMem
- `_beginio` (0xa18): ioreq->io_Device -0x1e (BeginIO) thunk
- `_divs` (0xa2c) / `_divu32` (0xa5e): 32÷32 signed/unsigned division
