---
type: Library
title: launcher.library 41.9
description: >-
  'launcher.library 41.9 (5.2.96)' — OS 3.x program-launcher
  service library; 2 hunks; InitTable+functab in the DATA hunk;
  5 vectors.
files:
  - source/launcher_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# launcher.library 41.9

Two hunks: CODE ~3136B + DATA 72B.

- Resident@h0+4: AUTOINIT fl=0x80 v41, name->h0+0x1e
  'launcher.library', id->h0+0x2f 'launcher.library 41.9
  (5.2.96)\r\n', init->h1+0x38 InitTable
- InitTable@h1+0x38: dsz 0x64, functab->h1+0x1e, dtab=0,
  initfn->h0+0x9f2
- functab@h1+0x1e: 5 absolute longs -> h0 + ffffffff
- h1 strings: 'CON:0/25/640/150/' output-window spec and
  '/AUTO/WAIT' option template
- h0 deps: icon.library, dos.library, 'TOOLPRI' env var
- initfn creates a handler task (FindTask/FindName/WaitPort/
  GetMsg/Signal loop visible in the trace)

## Build

`launcher_h0.s` verbatim .text + raw hunk1 .data; `fixup.py`
splices the original RELOC32 tails.  Byte-identical.

## Runtime

`work/oracle.py`: init (TaggedOpenLibrary dos v37, task
creation + message handshake), all 5 vectors, open x2, close
x2, expunge.  Identical original vs rebuild.
