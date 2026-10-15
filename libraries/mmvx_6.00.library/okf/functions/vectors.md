---
file: vectors
---
# Vectors

41 LVOs (-6 .. -246), absolute functab@h0+0x1a8 ->h0.

open/close/expunge/reserved + 37 MMXV API entries. Observed:
close/expunge do OpenResource(-552) lookups, CloseLibrary(-252),
FreeMem(-210) 112B; user vectors return 0x7b sentinel under stub
resource. initfn: node fill + OpenResource('mmvx' resource name
@h0+0xd57) -> h0+0xd70.
