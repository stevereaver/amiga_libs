---
type: Library
title: launcher.library 41.9 (5.2.96, Commodore)
description: >-
  Commodore launcher.library 41.9 — launches programs from icons /
  tooltypes via a resident server process; CODE+DATA hunks, 5 vectors,
  InitTable lives in the DATA hunk (cross-hunk rt_Init).
files:
  - source/launcher_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# launcher.library 41.9

Two hunks: CODE 3148B (hunk0), DATA 72B (hunk1).  `moveq #0; rts`
stub at h0+0, Resident@h0+4 (AUTOINIT, v41, NT_LIBRARY, pri 0,
EndSkip->h0+0xc4c).  rt_Init->h1+0x38: InitTable datasize 0x64,
functab->h1+0x1e (5 absolute longs + ffffffff), datatab=0,
initfn->h0+0x9f2.

- name 'launcher.library'@h0+0x1e, idstring
  'launcher.library 41.9 (5.2.96)' CRLF-terminated @h0+0x2f
- h1 strings: 'CON:0/25/640/150/' and '/AUTO/WAIT' (console spec)
- h0 embedded data block 0x2f0-0x31d: 'C:' struct, 'icon.library',
  'CLI', '"', 'TOOLPRI', 'dos.library'
- initfn opens dos.library 37 via exec TaggedOpenLibrary (-552),
  inits a semaphore at lib+0x22, clears lib+0x5c (server proc)
- first Open() from a CLI process spawns a resident server task
  (entry h0+0x50, NP_Entry) that signals the library list node
- the single API function (LVO -30) resolves a tool icon via
  icon.library, builds a command line and launches it through the
  server process

## Build

`launcher_h0.s` verbatim; resident+strings emitted raw (h0+4..0x50),
embedded data block raw (0x2f0..0x31e), hunk1 emitted raw as .data.
`fixup.py` splices the original header + RELOC32 tails (hunk0:
9->h0 + 3->h1; hunk1: 6->h0 + 1->h1).  Byte-identical
(md5 a8294a8da41334dbea47503c44567fe2).

## Runtime

`work/oracle.py`: init, open x2 (spawn branch), deferred+real
expunge, extfunc, launch fn x2 (Lock-fail path then success path),
spawned-task entry — identical original vs rebuild.
