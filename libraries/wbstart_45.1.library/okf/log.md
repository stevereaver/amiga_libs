---
type: Log
title: Work Log
description: Chronological journal of analysis sessions. Newest first.
---

# Log

## 2026-10-10
- Parsed two-hunk module: CODE 0x318, DATA 0x78.  Data hunk =
  functab (6 abs vectors + -1L), name, idstring, InitTable
  (dataSize 0x38, no InitStruct), RomTag (RT_VERSION 2!), EndSkip.
- Decoded vectors: open/close/expunge (DELEXP dance), reserved
  stub shared by -24/-30, WBStart @ -36.
- WBStart: NextTagItem loop over TAG_USER+1..7 (name, Lock,
  DupLock, 2 ignored, NumArgs, Args pairs); builds WBOPENA_
  ArgLock/ArgName taglist via AllocVec; PathPart+Lock+CurrentDir
  when no lock tag; OpenWorkbenchObjectA; returns 0 on success /
  20 otherwise.  dos LVO -876 confirmed as PathPart (fd bias 870).
- Reconstructed C + asm header; `make` builds; .data hunk is
  byte-layout identical to the original.

## 2026-10-15
- Byte-identical rebuild: `source/wbstart_h0.s` reassembles both
  hunks verbatim (md5 ab05a79789225bdf074a6f808ed4ca57).  Quirks
  preserved: noncanonical `addl %sp,%d4` (0xd88f) and
  `cmpl %a2,%d6` (0xbc8a) An-as-<ea> forms, `beqw` at +0x228,
  word-form `bsr.w` helper calls, PC-indexed tag jump table at
  +0x1c2 emitted as raw shorts, `addil #0x7fffffff` tag bias,
  pad word at +0x31a.
- Reloc tail is HUNK_DREL32 (0x3f7), word records attached to the
  DATA hunk: {7,hunk0: 00 04 08 0c 10 14 58} {6,hunk1: 50 5e 62
  6a 6e 72} + lone 0000 terminator; `source/fixup.py` splices it
  over GNU ld's RELOC32 after verifying the offset sets match.
- Runtime oracle (`work/oracle.py`, machine68k, 2-hunk AUTOINIT
  loader + DREL32 decoder): identical logs orig vs rebuild.
  WBStart returns 0 on success (workbench BOOL tested via
  `tstw d0` -- low word!), 20 (RETURN_FAIL) on missing name /
  AllocVec fail / OWO fail.  PathPart semantics confirmed:
  last '/' -> pointer AT it (name becomes p+1), ':' -> after it
  (lock "work:" for "work:proggy"), none -> arg (no lock).
