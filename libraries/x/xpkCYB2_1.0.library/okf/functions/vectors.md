---
file: vectors
---
# Vectors (abs-long functab @h0+0x86)

-6 Open +0x246 | -12 Close +0x254 | -18 Expunge +0x26e |
-24 +0x2be stub | -30 XpkPackerInfo +0x2c2 (PackerInfo
@CODE+0xfae: "CYB2"/"The lowlevel-xpkCYB", desc "The other
xpkCYB lib,(c) 1996 A.Nasr (The Cyborg)", sign 'CYB2',
flags 0x9, 1 mode desc "Wow!!" pspd=30 uspd=600) |
-36 XpksPackChunk +0x2cc | -42 +0xaaa | -48 +0xb26 |
-54 XpksUnpackChunk +0xb28 | -60 +0xc08.

Lowlevel variant: pack/unpack take direct args rather than
the xsp ctx of the SHR-family; under the SHR3 harness calls
return deterministic but meaningless values (different ABI).
