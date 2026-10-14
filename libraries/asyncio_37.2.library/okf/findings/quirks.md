# asyncio.library 37.2 — quirks

1. **Functab before the RomTag** — the MakeLibrary function table is at
   h0+4, *before* the RomTag (h0+0x78) and InitTable (h0+0x38).
   InitResident/AUTOINIT still finds everything via rt_Init; the stub
   `moveq #0,rts` at h0+0 doubles as the -24 null vector and the
   resident-scan landing pad.

2. **InitTable is a 4-long AUTOINIT data record** (dsize=0x22 → bare
   Library, no per-open data) — the lib keeps all state in the BSS
   hunk instead of lib-private storage, so the library is effectively
   non-reentrant across its globals.

3. **Globals in a BSS hunk** addressed through a hand-built `lea
   h1+0,a4` — all h0->h1 relocs are the lea operand sites.

4. No defects found in the verified paths: open×2/close accounting,
   deferred expunge, buffered read across boundaries, EOF short-read,
   seek-invalidation, char wrappers all behave consistently.
