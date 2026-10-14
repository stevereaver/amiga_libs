# Hunk and code layout

```
file 0x00  HUNK_HEADER (1 hunk, 0x22f longs)
code +0x00  error stub: moveq #-1,d0; rts        (hunk entry)
code +0x04  RomTag: MatchTag 4afc, MatchWord->+04,
            EndSkip->+0x8b8, RTF_AUTOINIT, v1, NT_LIBRARY, pri 0,
            Name->+0x1e, IdString->+0x33, Init->+0xaa
code +0x1e  "expname.library\0"
code +0x2e  "$VER:"                  (id string prefix, not referenced)
code +0x33  "expname.library 1.4 (20.7.95)\r\n\0"
code +0x53  banner "expname.library V1.4  (C) 1995 Richard Koerber
            e-mail: shred@tfh.dssd.sub.org   \r\n\0"
code +0xaa  InitTable (16 bytes)
code +0xba  functab: 5 absolute longs + -1
code +0xd2  datatab (InitStruct commands)
code +0xf2  LibInit
code +0x10e dead stub (moveq #0,d0; bra.s init-tail)
code +0x112 Open / +0x120 Close / +0x134 Expunge / +0x17c null
code +0x180 _fmtnum RawDoFmt helper
code +0x1a2 putchar stub  +0x1a6 "#%ld\0"  +0x1ab pad
code +0x1ac ExName
code +0x24a manufacturer table (22 x 12 bytes) + -1 long
code +0x356.. interleaved strings and product tables
code +0x80d orphan string "Blizzard 1230-II"
code +0x8b1 pad byte 0
code +0x8b2 libbase cell (written by init via absolute store)
code +0x8b6 nop
code +0x8b8 EndSkip: nop, nop
then       DREL16 hunk (108 offsets, descending, target hunk 0)
           END hunk
```

Library object: negSize 30 (5 vectors), posSize 0x4c (34 + 0x2c).
Data fields: +0x20 openCnt.w, +0x23 flag (bit0 deferred expunge),
+0x24 ExecBase, +0x28 seglist.
