# Findings & defects

- Extended 26-byte resident with an extra pointer field (links back
  into the late-body region 0x142e) — same Sas/C stub family as
  hgrexxsupport and virtualmem.
- -24/-30 return 0; several high LVOs return 0xf7 under synthetic
  args — deterministic in both binaries.
- Runtime produced ~1.34 billion deterministic invalid accesses
  under the stub environment (bitmap walkers over fabricated
  structures); identical counts in original and rebuild.
- Expunge leaves flags byte at 0 — library remains resident.
