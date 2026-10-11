# xpkSMPL 1.0 RE log

- IRA pass: functab resolved -- 10 vectors incl. two dedicated stubs
  (-24 `moveq #0`, -48 `rts`). codec = same flow as 1.2 with the
  1.1-style 24-B pointer nodes + byte lentab.
- Reconstruction: C port of the verified 1.2 codec; lib.s entry
  stub `moveq #-1` (1.0 genuinely differs from 1.2's `moveq #0` --
  verified against both binaries' hunk+0 bytes: 70ff vs 7000).
- Verified:
  - host round-trip 23/23 cases clean (zeros, repeats, ascending,
    low-entropy random, text, sizes 500-40000)
  - **byte-identical output streams vs verified 1.2 build** on all
    6 test inputs (codec semantics provably equivalent -- transitive
    verification vs the 1.2-independent Python model)
  - m68k build: functab resolves all 10 vectors (-24 -> stub
    0x182, -48 -> rts 0x186)
  - descriptor bytes identical modulo relocated pointers (SMPL,
    flags 9, MinPkIn 0x200, MaxPkIn/DefPkIn 0xfffe, DefMode 50,
    mode "normal" upto 100, pack mem 0x3710, unpack mem 0x1000)
- Differences vs 1.2 documented: 24-B node stride (link+freq+sym+
  parent+l+r+mark), byte lentab, len>=15 -> 8-bit `len-31` escape,
  separate allocs + Sub[0] cleared on free, no acc-wipe quirk.
