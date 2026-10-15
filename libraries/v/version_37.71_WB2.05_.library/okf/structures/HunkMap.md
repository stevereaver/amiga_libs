---
type: Structure
title: HunkMap
description: Hunk layout of the shipped binary.
timestamp: 2026-10-10T19:00:00Z
---

# Hunk map

```
HUNK_HEADER  2 hunks in table: [0x104, 0]
HUNK_CODE    hunk 0, 0x104 bytes   | all code+data
  +0x00      moveq #0/-1,d0; rts       | module entry
  +0x04      RomTag (0x4afc ...)       | ends +0x1e
  +0x1e      "version.library"\0
  +0x2e      id string + \r\n\0 (+pad)
  +0x48      InitTable (4 longs)
  +0x58      function table (4 longs + -1L)
  +0x6c      InitStruct data
  +0x8c      LibInit / LibOpen / LibClose / LibExpunge / LibNull
  +0x104      RT_ENDSKIP
HUNK_RELOC32 hunk 0, 14 offsets        | all .long backrefs into hunk 0
HUNK_END
HUNK_CODE    hunk 1, 0 bytes           | empty trailing code hunk
HUNK_END
```

File size 384 bytes.  The RELOC32 hunk covers every code-hunk
pointer: RomTag matchtag/endskip/name/idstring/init, the three
InitTable pointers, the four function-table entries and the two
InitStruct pointer payloads (ln_Name, lib_IdString).
