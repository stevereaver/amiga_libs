---
file: vectors
---
# Vectors (10 word-offset @+0x94, ffff marker)

-6 Open ->+0xb6 | -12 Close ->+0xc6 | -18 Expunge ->+0xda |
-24 hole ->+0x8 | -30 PackerInfo ->+0x11c |
-36 ->+0x146 | -42 ->+0x128 | -48 hole ->+0x10 |
-54 Pack/Unpack ->+0xaf6 | -60 hole ->+0x14.

PackerInfo struct @+0x1246: short "LINO1", long "Lino1
V1.1", desc "Ratio similar to FAST with faster packing",
banner msgs, mode table @+0x129e ('minimal' mode).
3 NULL holes (-24/-48/-60). -36/-42 = QueryPack/etc.
