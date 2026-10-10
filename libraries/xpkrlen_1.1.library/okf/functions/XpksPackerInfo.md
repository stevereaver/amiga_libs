---
type: Function
title: XpksPackerInfo (LVO -30)
---

# XpksPackerInfo

`lea 166(a4)` where a4=base+58 -> returns base+224, the
XpkInfo block that INITFUNCTION copied into the base.

Fields (old XpkInfo layout):
- ver words {1,0,0,0}
- Name -> "RLEN", LongName -> "Run Length 1.0",
  Description -> "Fast and simple compression usable for
  simple data"
- ID 'RLEN', flags 9
- MaxPkInChunk / DefPkInChunk = 0x7d00 (32000)
- PackMsg..UnpackedMsg all 0
- DefMode 50, ModeDesc -> single XpkMode node
  (upto 100, flags 1, packmem 0, unpackmem 0, packspeed 140,
  unpackspeed 1043, ratio 45, chunksize 0, desc "normal")
