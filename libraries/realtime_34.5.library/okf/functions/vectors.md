---
file: vectors
---
# Vectors (abs-long functab @h0+0x7a, 20 entries + -1)

Entry 0 (-6 Open) is 0 — MakeLibrary leaves that slot
pointing at its default, so only 19 vectors get installed:
-12 Close +0x140 | -18 Expunge +0x160 | -24 +0x1a6 (stub,
shared by -90..-114) | -30 +0x27c | -36 +0x2a6 |
-42 +0x884 | -48 +0x8d6 | -54 +0x394 | -60 +0x98a |
-66 +0x948 | -72 +0x90a | -78 +0x92c | -84 +0x6fa.

initfn opens utility.library v37 + both ciaa/ciab
resources (exec -558 x2), wires exec -564/-570 (ICR vector
add/rem) and AllocMem/FreeMem for timer bookkeeping —
the classic CIA-based realtime scheduler pattern.
