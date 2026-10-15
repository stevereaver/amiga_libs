---
file: vectors
---
# Vectors (abs-long functab @h0+0xec, 5 entries + -1)

-6 Open +0xb0 | -12 Close +0xb6 | -18 Expunge +0xbe
(does exec Remove + CloseLibrary(dos)) | -24 reserved
+0xc4 | -30 +0x24c — the real worker (calls exec -198
AllocSignal-ish with a0=sample ptr).

Oracle: init -> OpenLibrary(dos) + MakeLibrary + AddLibrary;
all 5 vectors exercised; expunge unwinds cleanly.
