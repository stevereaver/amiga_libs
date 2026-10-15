---
type: Log
title: SysInfo 2.00 work log
---

- Parsed 3 hunks: CODE 0xb70, DATA 0x1c (InitTable@+4), CODE 0x6c
  (16-entry functab + 'SysInfo.library' + 't:...' idstring).
- Verbatim transcription; pad-word merge at 0x1e fixed by ending
  the raw head at 0x22.  fixup.py splits the .data blob into
  DATA+CODE hunks and splices 5 reloc groups.  Byte-identical.
- Oracle: 3-hunk load, all 16 vectors, deferred+real expunge —
  identical logs original vs rebuild.
