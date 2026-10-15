---
type: Finding
title: Compact 16-bit relocation chunk (0x3f7)
description: The file tail uses the word-sized RELOC32SHORT/DREL16 record, not long RELOC32.
---

# Hunk tail: 0x3f7 compact relocations

Kickstart 1.x-era tools emitted the relocation tail in a 16-bit record
format (chunk id `0x3f7`, commonly called RELOC32SHORT or DREL16):

```
long   0x000003f7                 ; chunk id
repeat:
  word   count                    ; == 0 terminates
  word   target_hunk
  word   offset[count]            ; 16-bit code offsets
pad to 4-byte boundary
long   0x000003f2                 ; HUNK_END
```

This library's tail is a single group: `count=8, hunk=0`, offsets
`0x28 0x24 0x20 0x18 0x14 0x10 0x08 0x04` (descending) -- the eight
relocated longs: matchtag, endskip, name, idstring, init, functab,
datatab, initfunc.  The InitTable scalar `dataSize` (0x3c @ hunk+0x1c)
is deliberately NOT relocated.

Each stored longword is the target's code-hunk offset (module loaded at
base 0); the loader adds the segment address at LoadSeg/InitResident
time.  The offsets are word-sized so the format only works for hunks
< 64 KiB -- fine for a 560-byte hunk.

GNU ld has no switch for this form: `fixup.py` parses the emitted
`HUNK_RELOC32` (0x3ec) tail, verifies the offset set, and rewrites it.
The machine68k oracle parses both 0x3ec and 0x3f7 tails.
