---
file: vectors
---
# Vectors (12 abs-long @h1+0x34)

-6 Open +0x3dc | -12 Close +0x3f4 | -18 Expunge +0x41c |
-24 +0x47a | -30 +0x526 | -36 +0x5b6 | -42 +0x6f0 |
-48 +0x490 | -54 +0x63c | -60 +0x72a | -66 +0x758 |
-72 +0xb9a.

initfn @h0+0x320 opens dos37 + graphics39 + icon37.
Vectors do exec -294/-198/-210 allocs, lib2 -948 runs
(icon.library calls — likely DrawIconImage dispatch),
exec -684/-690 semaphore ops. 0 invalids.
