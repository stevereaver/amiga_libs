# asyncio.library 37.2 — quirks & defects

1. **CloseLibrary(NULL)** — `_freelib` guards only DOSBase before
   closing; UtilityBase is closed unconditionally. If init opened
   dos.library but utility.library failed, `CloseLibrary(0)` is
   executed (oracle log: `closelib 0`).

2. **Double Close on alloc failure** — when the AllocVec retry loop
   gives up, `_openworker` closes the filehandle itself (ownsFH) *and*
   returns NULL; `OpenAsync` then calls dos Close on the same handle a
   second time (oracle log: two consecutive `dclose` calls).

3. **Overlapping-instruction idiom** (SAS/C artifact): at 0x5ac,
   `bles 0x5b6` jumps into the middle of `cmpiw #0x70ff,d0` at 0x5b4 —
   the immediate word `0x70ff` decodes as `moveq #-1,d0`, which is the
   real error path of ReadCharAsync. Requires raw `.short` emission.

4. **rt_EndSkip → Expunge** — the RomTag's endskip field is h0+0x190,
   the start of the Expunge function, not past the resident struct.

5. **Function table before RomTag** — the 12-long absolute function
   table sits at h0+4, ahead of all the library metadata; InitTable
   (rt_Init target) is at h0+0x38 between the strings and the RomTag.

6. **mn_ReplyPort never set** — sp_Msg's reply-port field (+46) is
   left as AllocVec garbage; the packet protocol relies solely on
   dp_Port → &af_PacketPort.

7. **Flag-reuse codegen** — `af_ReadMode = (mode==0)` is computed by a
   `seq;negb;extw;extl` chain that tests the Z flag left behind by the
   earlier `movel %d1,%sp@(40)` store, not by an explicit compare.

8. **Mode index unchecked** — `OpenAsync` uses `mode` directly as an
   index into a 3-entry word table; out-of-range values read garbage.

9. **Synchronous flush** — write-mode SeekAsync/CloseAsync flush via
   plain dos Write, not a packet; only read prefetch is truly async.

10. **Split SeekAsync exit** — two distinct epilogue targets: 0x7e6
    (`movel %d7,%d0` — return computed position) and 0x7e8 (moveml —
    return the -1 already in d0). Error branches skip the mov.

11. **PA_SIGNAL/PA_IGNORE toggling** — the embedded packet port's
    mp_Flags is set to PA_SIGNAL only around WaitPort, back to
    PA_IGNORE after Remove — the AsyncFile lives in the caller's task.

12. **AllocVec retry-shrink** — on alloc failure the worker shrinks
    bufsize by 2·blocksize and retries; give-up when buf ≤ 2·bpp.
