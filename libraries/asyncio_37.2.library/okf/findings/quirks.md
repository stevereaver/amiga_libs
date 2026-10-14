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
   h1+0,a4` (abs-long, `.short 0x49f9`) — all h0->h1 relocs are the lea
   operand sites.

4. See `defects.md` for the verified defect list (CloseLibrary(NULL)
   on utility-open failure, double Close on alloc failure, the
   mid-instruction `moveq #-1,d0` branch target, rt_EndSkip→Expunge,
   uninitialized mn_ReplyPort, unchecked mode index).
