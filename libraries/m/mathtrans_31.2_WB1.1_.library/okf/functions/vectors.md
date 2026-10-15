---
file: vectors
---
# Vectors

21 absolute-long vectors @h0+0x8c -> h0/h2 targets:
-6 Open 0x126 | -12 Close 0x162 | -18 Expunge 0xe4 |
-24 reserved 0x5c | -30..-126 17 math funcs in h2
(0x208e..0x2106 incl. 0x207a/0x2084 sin/cos-family helpers).

Vector traces: math ops exercise the linked FP firmware
(exec-528 style dispatch); -24/-36/-48/-84/-114/-120/-126
return small constants/flags; deterministic invalid reads at
0xffffff2e+ under stub emulation. Expunge -> 0.
