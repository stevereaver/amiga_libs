---
type: Library
title: SysInfo.library 2.00 (20.2.97)
description: >-
  SysInfo.library 2.00 (The Pool/Executive_server) — 16-vector
  AUTOINIT library in a 3-hunk layout (CODE + InitTable DATA +
  functab/strings CODE).
files:
  - source/SysInfo_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# SysInfo.library 2.00

Three hunks:

- hunk0 CODE 2928B — `moveq #0,rts` stub at +0, Resident at +4,
  all code; carries '$VER: SysInfo.library 2.00 (20.2.97)' at
  +0x1f9 and port name 'Executive_server' at +0x220
- hunk1 DATA 28B — dead long then InitTable at +4:
  datasize 0x4c, functab->h2+0, datatab=0, initfn->h0+0x20;
  a fifth long at +0x14 relocates to h0+0x1fa (into the $VER
  string, one past the '$')
- hunk2 CODE 108B — 16-long absolute functab + 0xffffffff, then
  'SysInfo.library' and idstring 't:SysInfo.library 2.0'
  (note the literal 't:' prefix quirk) + 2 tail bytes

## Vectors (16, -6..-96)

Lifecycle at -6/-12/-18, -24 -> the hunk0+0 `moveq#0;rts` stub.
User vectors wrap exec message-port traffic for the
'Executive_server' task (CreateMsgPort/FindPort/semaphore calls
observed; -66/-72 return -1 on stubbed ports).

## Build

Verbatim transcription `SysInfo_h0.s`; `fixup.py` splits the
linked .data blob back into the DATA + trailing-CODE hunks,
restores the 3-hunk header, and splices all five original
RELOC32 groups (h0->h0, h0->h1, h0->h2, h1->h0, h1->h2).
Byte-identical (md5 10d032b1a7fae90a0eddd8c8272cc417).

## Runtime

`work/oracle.py` runs the 3-hunk layout, initfn, all 16 vectors,
deferred + real expunge; logs identical between original and
rebuild.
