---
file: vectors
---
# Vectors

16 word-offset vectors @h0+0x108 (ffff-marked):
ffd2 ffe6 ff90 ff60 0204 0214 0226 022e 0236 023e 0246 024e
0256 025e 026c 0266 -> targets 0xda 0xee 0x98 0x68 0x30c..0x374.

-6 Open 0xda | -12 Close 0xee | -18 Expunge 0x98 |
-24 reserved 0x68 | -30..-102 IEEEDP basic ops (per symbol
names: Abs, Add, Div, Cmp, Fix, Flt, Neg, Ceil, Floor, Mul,
Sub, Tst + df* helpers). Returns include 0x40600000-style
double bit patterns. Expunge -> 0.
