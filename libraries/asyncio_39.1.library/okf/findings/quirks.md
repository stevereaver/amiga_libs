# asyncio.library 39.1 — quirks

1. **Functab before the RomTag** — the MakeLibrary function table is at
   h0+4, *before* the RomTag (h0+0x8c) and InitTable (h0+0x4c).
   InitResident/AUTOINIT still finds everything via rt_Init; the stub
   `moveq #0,rts` at h0+0 doubles as the -24 null vector and the
   resident-scan landing pad.

2. **InitTable is a 4-long AUTOINIT data record** (dsize=0x22 → bare
   Library, no per-open data) — all state lives in the BSS hunk, so
   the library is effectively non-reentrant across its globals.

3. **Globals in a BSS hunk** addressed through a hand-built
   `lea 0:l,a4` (abs-long, opcode `49f9`, operand = hunk1 reloc slot)
   — all ten h0→h1 relocs are these lea operand sites.  See
   `defects.md` — OpenAsyncFromFH forgot to emit it.

4. **Three `cmpiw` instruction-hiding tricks** (SAS/C-style dual
   branch targets landing mid-instruction):
   - h0+0x620 `cmpiw #0x70ff,d0` — `bles` from 0x618 lands at 0x622
     executing `moveq #-1,d0` (ReadCharAsync error path).
   - h0+0x4fc `cmpiw #0x2200,d0` — `bges` from 0x4f8 lands at 0x4fe
     executing `movel d0,d1` (PeekAsync min() selection).
   - h0+0xbfe `cmpiw #0x2008,d0` — `bnes` from 0xbfa lands at 0xc00
     executing `movel a0,d0` (FGetsLenAsync returns buf vs 0).

5. **WriteLineAsync appends no newline** — documented in the autodoc;
   it is literally `strlen(a1)` + `WriteAsync(file,str,len)`.

6. **SeekAsync beyond-EOF syncfail machinery (new in V39)** — when a
   read-mode seek target exceeds fib_Size, SeekAsync sets
   af_SyncFail(+145)=1, SetIoErr(219=ERROR_SEEK_ERROR), then
   RecordSyncFailure parks dp_Res1→+146 and af_BytesLeft→+150,
   stores dp_Res1=-1 / dp_Res2=IoErr / af_BytesLeft=0 and returns -1.
   The NEXT WaitPacket-driven call sees Res1<0, notices the flag,
   restores the saved Res1/BytesLeft and proceeds as if the packet
   succeeded — keeping the buffer state coherent after a failed seek.
   The flag is cleared at the SeekAsync epilogue (h0+0x996) which also
   restores dp_Res1 from +146 and SetIoErr(0).

7. **rt_EndSkip → Expunge** (h0+0x1a8) instead of past the resident
   struct — harmless (resident scanning stops at endskip, which is
   *before* the rest of the code).

8. Write-mode AsyncFile on a handler-less file (af_Handler==0, e.g.
   NIL:) short-circuits WriteAsync to "all written" without touching
   the packet machinery.

9. Mode index table is WORD-sized in V39 (`movew a0@(0,d2:l)` with
   d2=mode*2 into {1005,1006,1004} at h0+0x2ae) — V37 used byte
   doubling too but the code is tighter; still no bounds check on the
   mode argument.
