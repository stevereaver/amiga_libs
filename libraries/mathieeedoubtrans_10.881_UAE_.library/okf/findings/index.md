---
type: Index
title: Findings
description: Quirks, open questions, and version differences for this library.
---

# Findings

- [reconstruction_delta.md](reconstruction_delta.md) — byte-identical rebuild: verbatim .s + 0x3f7 tail fixup
- [shared_tails.md](shared_tails.md) — code-sharing quirks, in-CODE seglist cell, rt_Name inside the NoFPU path
- [hunk_tail.md](hunk_tail.md) — compact 16-bit relocation chunk format
- [fpcr_open.md](fpcr_open.md) — FPCR write performed by Open (unconditional 0x10)
- [nofpu_init.md](nofpu_init.md) — init-routine behaviour without a coprocessor
- [pow_edges.md](pow_edges.md) — Pow / conversion edge cases, verified deviations
- [uae_twin.md](uae_twin.md) — identical byte-for-byte twin
