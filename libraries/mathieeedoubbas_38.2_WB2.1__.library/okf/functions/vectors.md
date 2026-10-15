---
file: vectors
---
# Vectors (16, attn/fpsp-selected functabs)

COLDSTART init @h0+0x72: stores seglist, probes
fpsp.resource + AttnFlags, picks one of several functabs
(matrix: functab@0x1e8 for default/48, 0x20c path when
fpsp missing), MakeLibrary -> lib hdr type 9 flags 6
ver 38 rev 1, neg=96 pos=60.

Vectors: open/close/expunge + IEEEDP* ops; vector call
targets logged per matrix run. FPU fline stubs used on
fpsp path; software fallbacks otherwise. Deterministic
across all 9 init combos.
