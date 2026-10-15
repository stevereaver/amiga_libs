---
file: layout
---
# calculus 37.3 layout

File 4744B. 2 hunks: h0 CODE 0x457 longs (4444B @0x24,
clean), RELOC32 20 slots ->h0; h1 DATA 0x13 longs (76B
@0x120c) — pairs of (h0 code offset, tag) relocated into
h0 — RELOC32 6 slots ->h0.

Resident @h0+4: flags 0 (COLDSTART), ver 1 (id string says
37.3 (15-09-95) — the resident ver field is a marker, real
version only in the idstr), type 9; name/id ->
"calculus.library" / "calculus.library 37.3 (15-09-95)";
init -> h0+0x52 code.

initfn @h0+0x52: SAS/C a4-frame (lea 0x7ffe -> h1); probes
version-check stubs @h0+0x1094/0x109c (moveq stubs), then
jumps to the real init @h0+0x104 which opens dos.library,
calls MakeLibrary(functab@h0+0xec, dsize 0x22), AddLibrary.
