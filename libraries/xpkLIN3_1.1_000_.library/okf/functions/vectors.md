---
file: vectors
---
# Vectors (10 word-offset @+0x94, ffff marker)

-6 Open ->+0xb4 | -12 Close ->+0xc2 | -18 Expunge ->+0xd4 |
-24 hole ->+0x0 | -30 PackerInfo ->+0x138 |
-36 ->+0x140 | -42 ->+0x112 | -48 hole ->+0x0 |
-54 Pack/Unpack ->+0xb6c | -60 hole ->+0x0.

PackerInfo @+0x1310: short "LINO3", long "Lino3 V1.1",
desc "Improved version of LIN1, better packing (like PP)",
banner msgs (typo "Comressing"), mode table @+0x1368
('minimal').
