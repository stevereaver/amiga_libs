# Findings & defects

- Extended 26-byte resident (extra ptr -> h0+0x14dc), same Sas/C
  stub family as hgrexxsupport/virtualmem/multifunction.
- Close underflows opencnt to 0xffff when called once too often
  (oracle drove 2 closes past count 1) — deferred-expunge path
  then runs Remove+CloseLib(dos)+FreeMem unconditionally.
- v-30 returns -17 under null args; v-36 frees an 80-byte ctx.
- Zero invalid accesses — clean run under synthetic stubs.
