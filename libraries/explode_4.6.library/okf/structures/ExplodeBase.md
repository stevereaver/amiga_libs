# ExplodeBase (dataSize 0x36)

| Off | Field | Notes |
|-----|-------|-------|
| +0x22 | xb_dosbase | DOSBase from OldOpenLibrary |
| +0x26 | xb_seglist | init seglist |
| +0x2a | xb_opencnt | private open counter (LibOpen) |
| +0x2e | xb_stub_ctr1 | decrunch count (HookCount patch target) |
| +0x32 | xb_stub_ctr2 | bytes emitted (ByteCount patch target) |
