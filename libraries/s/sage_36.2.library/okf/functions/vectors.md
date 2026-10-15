---
file: vectors
---
# Vectors

10 absolute-long vectors @h0+0xe5c ->h0:
-6 Open 0x17a | -12 Close 0x19a | -18 Expunge 0x10e |
-24 reserved 0x1a | -30..-66 user funcs (0x5d4 0x9fc 0xa3c
0xd84 0xbe2 0xdf0) — SAGE API entry points.

Init opens graphics.library v33; initfn returns 0 under stub
emulation (open fails) but vectors still install. Deterministic
unmapped table reads 0xffffffac+ and a walk through
0xfffffff* in a vector path. Expunge -> 0.
