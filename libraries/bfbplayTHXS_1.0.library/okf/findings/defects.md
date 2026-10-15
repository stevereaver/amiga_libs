# Findings & defects

- Extended 26-byte resident, same Sas/C stub family as bfbplayBMOD /
  hgrexxsupport / virtualmem / multifunction.
- **Open-count underflow (same family as bfbplayBMOD):** Close does an
  unconditional `subq.w #1,lib+0x20` (h0+0x176) with no guard; oracle
  drove 2 closes past count 1 -> cnt=0xffff, and the deferred-expunge
  path then ran Remove + CloseLibrary(dos) + FreeMem anyway.
- Self-modifying dependency name: h0+0x66e writes 'b' over
  "ciaa.resource"[3] to reuse the same in-hunk string for ciab; the
  patch is permanent after the first StartModule (same trick as
  bfbplayGMOD).
- Requires AttnFlags bit1 (AFF_68020) in both InitModule and
  StartModule paths -> -14 on plain 68000 despite the rest of the code
  being 68000-clean (period table + mixing math only).
- Error codes: -6 Open fail, -8 AllocMem fail, -13 resource/int setup,
  -14 CPU gate, -15 CIA/timer arm fail, -17 null/tag missing.
- v-60/v-66 are dead stubs returning -1; v-24 reserved stub returns 0.
- Zero invalid accesses under machine68k oracle; RUNTIME-IDENTICAL.
