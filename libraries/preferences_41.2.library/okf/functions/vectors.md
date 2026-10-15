---
file: vectors
---
# Vectors (14 abs-long @h1+0)

-6 Open +0x62 (opencnt @lib+0x20, gate @lib+0x26, helper
0x4015a opens intuition/utility/iffparse/dos v39, AllocVec
0x2000 -> lib+0x56) | -12 Close +0x9c (deferred-expunge
bit3 @lib+0xe) | -18 Expunge +0xc0 | -24 stub +0x11c |
-30 +0x25c (Obtain/ReleaseSemaphore on lib+0x28/+0x5a,
exec -708) | -36 +0x2ee | -42 +0x36c | -48 +0x47e
(-678 FindName-ish) | -54 +0x53e | -60 +0x70c (lib2 -30) |
-66 +0x98c | -72 +0xa2a | -78 +0xba0 | -84 +0xc7c.

SAS/C initfn @h0+0xe: d0=libbase fills ver=2 @lib+0x16,
seglist @lib+0x22; helper 0x4012c does 2x InitSemaphore.
