---
file: vectors
---
# Vectors (22 abs-long @h0+0x174)

-6 Open +0xf6 | -12 Close +0x104 | -18 Expunge +0x116 |
-24 +0x170 | then +0x1d0/+0x1e2/+0x29e/+0x2b2/+0x2c2/
+0x5dc/+0x5ea/+0x5f4/+0x324/+0x2da/+0x2d6/+0xad2/
+0xaac/+0xbfc/+0x584/+0x5d2/+0x9fc/+0x6aa.

initfn @h0+0xb8: 3x exec -408 (AllocSignal-ish probes)
then installs. User vectors drive the PP crunch/decrunch
core: AllocMem buffers, tight inner loops (millions of
invalid-lite accesses under the oracle from raw pointer
walks past mapped arenas — deterministic).
