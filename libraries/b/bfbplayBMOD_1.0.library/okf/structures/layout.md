# Layout

- Single CODE hunk, 0x537 longs (5340B body).
- body+0: reserved-slot stub; +4: 26B extended resident;
  +0x1e name; +0x32 id + dep/magic strings; +0x92 InitTable;
  +0xa2 functab (15 entries, ffffffff @+0xd6).
- RELOC32 tail: 1 group, 28 offsets ->h0.
