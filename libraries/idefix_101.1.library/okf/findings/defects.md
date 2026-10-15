# Findings & defects

- Close underflows open count (cnt=65534 after double close).
- Functab has duplicated dead entries pointing at the h0+0
  moveq/rts stub (indices 3,13,14).
- initfn returns 0 under stubs after freeing its allocation;
  AddDosEntry + dos calls trace the IDE fix registration.
- ~7 deterministic invalid reads probing past functab.
