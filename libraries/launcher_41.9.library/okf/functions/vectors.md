---
type: Functions
title: launcher.library 41.9 vector map
---

# Vector map (functab h1+0x1e, 5 absolute longs + ffffffff)

| LVO | target  | role |
|-----|---------|------|
| -6   | 0xa5e | Open — inc opencnt, clr DELEXP; first open from a CLI task spawns server proc (dos -498 + tag list incl NP_Entry=h0+0x50), PutMsg + Wait(0x10) handshake |
| -12  | 0xbda | Close — dec opencnt; at 0 + DELEXP -> bsr Expunge |
| -18  | 0xb6e | Expunge — if server proc (lib+0x5c) -> Signal(proc,0x1000)+set DELEXP, ret 0; else CloseLibrary(dos)/Remove/FreeMem, ret seglist |
| -24  | 0xc26 | reserved/extfunc — returns 0 |
| -30  | 0x4b6 | launch — a0=tool/icon name, d0=mode 0..2 (else Alert ~46); icon GetDiskObjectNew, WBTOOL/WBPROJECT only (err 212), FindToolType 'CLI'/'TOOLPRI', resolve cmd path (CLI dirs+resident scan via h0+0x31e), open CON: window, build 74B+ startup msg, PutMsg to server port lib+0x60 |

## Non-vector code (hunk0)

| off | role |
|-----|------|
| 0x00  | `moveq #0,d0; rts` module entry stub (before resident) |
| 0x50  | spawned server-task entry: FindName lib in LibList, stores self @lib+0x5c, drains pr_MsgPort startup msg, creates port @lib+0x60 (exec -666), msg loop handling launch packets, Signal(caller,0x10) on exit |
| 0x31e | command resolver: walks cli_CommandDir path list + resident scan (dos -522/-528/-642/-648) for the tool; restores pr_WindowPtr=-1 suppression |
| 0x9f2 | initfn — exec base -> lib+0x54, TaggedOpenLibrary(37) dos -> lib+0x58, sets ln_Type=9/ln_Name/flags=6/ver 41/rev 9/idstr, seglist -> lib+0x50, InitSemaphore lib+0x22, lib+0x5c=0 |
| 0xc34 | internal strcat (bsr'd from launch fn) |
| 0xc4a | 2B pad to long boundary |
