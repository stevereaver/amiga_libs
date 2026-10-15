---
file: defects
---
# Findings

- DREL16 relocations (word-sized tables) — unusual vs
  RELOC32; tail has 4 groups incl. 97 slots ->h2.
- init returns 0 under missing-dos stub but vectors stay
  installed (oracle quirk, deterministic).
- 138 invalid reads at negative addrs (vec -30/-36 walk
  pre-bss area) — deterministic.
