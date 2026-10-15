---
file: defects
---
# Findings

- initfn requires AttnFlags bit 1 set (68020+) — on a bare 68000
  it branches to the +0 `moveq#-1` stub and MakeLibrary fails;
  the 020 build ships this guard deliberately.
- Unpack of garbage/bad-trailer input spins through unmapped
  reads (719M invalid accesses in the oracle) before returning
  junk in d0 — deterministic but unbounded-looking.
- -42 ctx-free and -60 alias the same +0x128 routine.
