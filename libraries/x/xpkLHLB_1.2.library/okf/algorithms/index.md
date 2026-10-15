---
type: Algorithm
title: xpkLHLB 1.2 codec observations
tags: [lz, lhlb]
timestamp: 2026-10-15T00:00:00Z
---

# LHLB codec observations (from oracle runs)

- Pack state: 40000B clear-mem table + 28B ctx; output staged in a
  36864B scratch (xsp_Sub[1]) then CopyMem'd into xsp_OutBuf.
  Chunk budget 0x8000 written into ctx+12 by the packer.
- Unpack state: 4500B + 28B ctx; decompresses directly into
  xsp_OutBuf bounded by xsp_OutBufLen.
- Example: 2048B of periodic data packs to 462B; chained second
  chunk (74B in) -> 74B... stream state preserved across calls.
- The packed stream has no ASCII magic/header visible at offset 0;
  format details live in the 020 code at CODE+0x320 (pack engine)
  and CODE+0x348 (unpack engine) plus the static tables at
  +0x57a..+0x7f6 / +0xb04..+0xb84.
- "preprocessor for lh.library" is legacy naming — no lh.library
  interaction occurs anywhere in the binary.
