---
file: defects
---
# Findings

- Resident ver=0 while id string says 1.2 — version field
  never bumped.
- Extended 26-byte resident with extra pointer @+6
  (->InitTable) and self-referential EndSkip — same stub
  generator as hgrexxsupport (both H.Goebel-era builds).
- initfn returns 0 when deps missing but lib stays
  installed (deterministic under stubs).
- No invalid accesses.
