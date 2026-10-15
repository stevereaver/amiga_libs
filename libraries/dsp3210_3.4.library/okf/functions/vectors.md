---
file: vectors
---
# Vectors

14 absolute-long vectors @h0+0x170:
-6 Open 0x102 | -12 Close 0x112 | -18 Expunge 0x12c |
-24 reserved 0x16e | -30 DSPCalcLen 0x1ae | -36 DSPRelocate
0x23c | -42 0x246 | -48..-90 d32 ops 0x9aa/0xb44/0xb9c/0xb70/
0xbda/0x9b6/0xdce.

Oracle: entry->1, MakeLibrary(14 vecs dsize 0x2c), libInit ok.
DSPCalcLen valid d32 blob -> 4; DSPRelocate -> -3 (0xfffffffd)
with AllocMem; bad magic -> -1 both. Expunge frees mem.
