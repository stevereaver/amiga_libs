# Layout

- Single CODE hunk, 0x586 longs (5656B body), file 5840B.
- body+0: `moveq #-1,d0;rts` reserved-slot stub; +4: 26B extended
  resident (MatchTag->+4, EndSkip->+0x1618).
- +0x1e name; +0x32 id; +0x5a "dos.library"; +0x66 "ciaa.resource"
  (self-modified to "ciab.resource" by h0+0x66e `moveb #'b',a1@(3)`);
  +0x74 "THX Sound-System"; +0x85 long credit string; +0x79c
  "BFBPlay CIA timer." (interrupt node name).
- +0xd8 InitTable (dsz 0xb2); +0xe8 functab (14 entries,
  ffffffff @+0x140); +0x124 InitData (byte-identical blob to
  bfbplayBMOD sibling); +0x144 initfn.
- lib+0x24 execbase stash, +0x28 dosbase, +0x2c seglist,
  +0x9f/0x9e CIA period bytes, +0xa0 ciaa base, +0xa4 ciab base,
  +0xa8/+0xac/+0xb0 installed-int bookkeeping.
- Session ctx (80B): +0x1 playing flag, +0x2 module, +0xa modsize,
  +0xe song header, +0x14 subsong count, +0x18 cur subsong,
  +0x26 names table (+0x2a size), +0x2e paused, +0x2f cia-started,
  +0x38 started flag.
- RELOC32 tail: 1 group, 33 offsets ->h0
  (0x6..0x798, incl. all functab/InitTable/resident pointers).
