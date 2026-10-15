---
type: Log
title: Work Log
description: Chronological journal of analysis sessions. Newest first.
---

# Log

## 2026-10-10
- Parsed two-hunk module: CODE 0x5a4, DATA 0x98.  Data hunk =
  functab (6 abs vectors + -1L), name, idstring, InitTable
  (dataSize 0x38, no InitStruct), RomTag, EndSkip.
- Idstring reveals this is a clean-room "Emulation by Stephan
  Rupprecht" of the 45.1 original — not Commodore code.
- Decoded vectors: open/close/expunge (DELEXP dance), reserved
  stub shared by -24/-30 (`clr.l d0` this time), WBStart @ -36.
- WBStart: NextTagItem loop over TAG_USER+1..7; builds WBOPENA_
  ArgLock/ArgName taglist via AllocVec; object start is
  reimplemented: "VOL:" opens directly, "dev:dir/file" probes
  Lock(name)/Lock("name.info") then ParentDir+CurrentDir+
  FilePart, bare names fall back to the Workbench search path
  (WBCTRLA_DuplicateSearchPath) and PrintFault on failure.
- Quirks recorded: RomTag RT_VERSION 2 + runtime self-patch of
  that byte, CloseLibrary(NULL) crash path on init failure,
  68000-illegal `tst.l a0` (0x4a88) in the tag loop, dead
  strcat/strcpy code at end of the code hunk.
- Reconstructed C + asm header; `make` builds a valid
  `wbstart.library`.

## 2026-10-15
- Byte-identical rebuild: `source/wbstart_h0.s` reassembles both
  hunks verbatim (md5 `45964497863bb8fbb534faed27da44fa`).  Quirks
  preserved: noncanonical `addl %sp,%dN` (0xd68f/0xd48f/0xda8f)
  and `tstl %aN` (0x4a88/0x4a8b) forms, `lea 0x0,%aN` absolute-word
  NULL loads, `beqw` at +0x244/+0x320/+0x458, word-form `bsr.w`
  helper calls, stack-arg openlibs/closelibs, PC-indexed tag jump
  table at +0x3ec emitted as raw shorts (`303b 0a06` uses
  d0.l*2 — no pre-doubling unlike 45.1), pad words + trailing
  `0x0002` at +0x59a.
- Reloc tails are plain HUNK_RELOC32 on BOTH hunks, but the CODE
  hunk's first group is non-sorted `{1dc, 1cc}` vs GNU ld's
  ascending emission; `fixup.py` splices the shipped tails after
  verifying the (hunk, offset-set) groups match.
- The two intra-hunk `jsr` calls (+0x1cc/+0x1dc) needed raw
  `0x4eb9` + `.long sym`: gas relaxes defined `.text` symbols to
  `jsr pc@(disp)`, which would shrink the hunk and drop the two
  hunk0 self-relocations.
- Runtime oracle (`work/oracle.py`, machine68k, 2-hunk AUTOINIT
  loader + RELOC32 decoder): identical logs orig vs rebuild.
  14 WBStart scenarios incl. `.info` retry, `dev:`/`dev:dir/f`
  resolution, WB search-path walk (hit + PrintFault miss),
  AllocVec/OWO failure.  Return convention confirmed: 0 on
  success, 20 (RETURN_FAIL) otherwise; startobj result tested
  via `movea.w` (low word of the workbench BOOL).
