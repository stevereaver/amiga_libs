---
type: Findings
title: launcher.library 41.9 quirks
---

# Findings / quirks

- InitTable lives in the DATA hunk (rt_Init relocates cross-hunk
  to h1+0x38) — resident scan finds the matchword in the CODE hunk
  while AUTOINIT data is elsewhere.
- functab at h1+0x1e is only word-aligned (long entries at odd
  longword boundary).
- idstring 'launcher.library 41.9 (5.2.96)\r\n' has no '$VER:'
  marker.
- `moveq #0,d0; rts` module-entry stub sits before the resident;
  nothing vectors to it.
- Uses exec-private LVOs: -552 TaggedOpenLibrary, -558
  InitSemaphore, -564/-570 Obtain/ReleaseSemaphore, -606, -642,
  -666/-672 (in-place msgport create/delete pair).
- Uses dos-internal LVOs: -498 (tagged process create — the
  NP_* tag immediates 0x800003e9..0x800003fc pushed on the stack),
  -522/-528/-642/-648 (resident/command scan), -606, -816,
  -870/-876 (string helpers).
- Alert() abuse on bad API args: Alert(~116) when icon name is
  NULL, Alert(~46) when mode is outside 0..2; also Alert(~50)
  on internal failures and Alert(-47) for invalid launch flags.
- Expunge signals the server proc with 0x1000 (SIGBREAKF_CTRL_C)
  and sets DELEXP rather than freeing — real free only once the
  server exits.
- Oracle caveat: machine68k emits 'INVALID: W(1)/W(2)' diagnostics
  for negative-address writes during the second launch call
  (emulator bookkeeping artifact) — identical on both binaries.
