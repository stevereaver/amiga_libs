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

- Lazy deps opened inside vectors: commodities.library (v-42,
  mkport+openlib+FreeVec-cleanup path), intuition+graphics (v-60,
  gfx -30/-342/-606/-636/-918/-924 + int -606), misc.resource (v-66,
  misc-6 unit ops). v-84 returns 0xffffffff; v-96 Allocs 156B ctx.
