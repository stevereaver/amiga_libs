---
file: vectors
---
# Vectors

29 absolute-long vectors @h0+4:
-6 Open 0x12c | -12 Close 0x1e8 | -18 Expunge 0x1a0 |
-24 reserved 0x254 | -30..-174 user funcs
(0x3ae..0x694 — container/property API: alloc/free/
get/set/enumerate style entry points).

Oracle-visible: initfn returns 0x1ac-ish handle; open bumps
lib+34; user vectors return small codes/flags and dispatch
through internal table lookups; several touch BSS-ish cells
at lib+0x22.. Expunge -> 0.
