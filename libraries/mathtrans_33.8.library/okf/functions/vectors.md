---
file: vectors
---
# Vectors

21 absolute-long vectors @h0+0x8c:
-6 Open 0x126 | -12 Close 0x162 | -18 Expunge 0xe4 |
-24 reserved 0x5c | -30..-126 math funcs (h0/h2 targets,
sin/cos/transcendental firmware calls).

Same skeleton as 31.2 — vector -102 site moved to h0+0x1b8.
Deterministic unmapped table reads at 0xffffff2e+ under
stub emulation; expunge -> 0.
