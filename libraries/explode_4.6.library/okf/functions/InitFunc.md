# InitFunc - InitTable initializer

Runs at MakeLibrary time (a5 = lib base, a0 = seglist):

1. `lib_OpenCnt = 1` (prevents expunge), seglist -> base+0x26.
2. `OldOpenLibrary("dos.library",33)` -> base+0x22; on failure a
   dead-end `jmp Alert(0x80038007)` (4.3 used a recoverable jsr).
3. Zero `xb_stub_ctr1` (+0x2e) and patch its address into the
   `addq.l #1,(abs)` inside LoadSegStub (HookCount); same for
   `xb_stub_ctr2` (+0x32) and the `add.l d0,(abs)` in the decode
   teardown (ByteCount).
4. `xb_opencnt` (+0x2a) = 0.
5. Probe DOS `LoadSeg` (-0x96) vector code: `JMP` style -> hook at
   stub+2, BCPL stub (`MOVEQ`/`BRA`) -> walk the dispatcher to the
   real target and hook at stub+0.  Failure -> Alert(0x00028007),
   no patch.
6. `SetFunction(dos, -0x96, LoadSegStub+d1)`, return base.
