# Layout

- Single CODE hunk, 0x50c longs (5168B body).
- body+0: `moveq #-1,d0;rts` reserved-slot stub.
- body+4: 26-byte extended resident (matchtag/endskip/extraptr/
  flags+ver/type+pri/name/idstring/init). ver 0x26=38.
- body+0x1e: name "multifunction.library"; +0x34: id string.
- body+0x7c: InitTable (dsize 0x62, ftab 0x8c, dtab 0x10c, initfn 0x140).
- body+0x8c: functab, 31 entries, `ffffffff` at +0x108; InitData at 0x10c.
- RELOC32 tail: one group, 53 offsets, all ->h0.
- Library private data: 0x62 bytes; neg size 0xba, pos 0x84.
