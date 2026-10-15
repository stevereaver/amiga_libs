---
file: defects
---
# Findings

- ver 0 resident despite "0.55" id; flags 0x81 has a stray
  low bit set alongside AUTOINIT.
- The real payload (h1, 3988B) is unreachable via vectors —
  installed only by patching a copied resident module's
  jump table. Under stub emulation FindName returns 0 and
  initfn bails cleanly (no patch applied); deterministic.
- Expunge is a stub (moveq #0/rts): the lib never unloads —
  once installed the patched module keeps it alive.
