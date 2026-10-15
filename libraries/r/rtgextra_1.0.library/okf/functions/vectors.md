---
file: vectors
---
# Vectors

15 LVOs (-6 .. -90), absolute functab@h1+0 ->h0:
+0xc4/+0xd6/+0x100/**0-hole**/+0x338/+0x158/+0xa62/+0xa32/
+0x3e0/+0xa92/+0xb1a/+0xbbc/+0xc34/+0xc72/+0xca4.

-6 open/-12 close/-18 expunge standard; -24 hole -> +0 stub.
User vectors call an external dispatch LVO (harness-labelled
'rexx-1194'-style) — RTG helper calls routed through a
register-based dispatcher. Expunge: Remove+FreeMem 448B,
returns stored seglist.
