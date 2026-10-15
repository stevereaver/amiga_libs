# i2c.library 40.1 — defects / quirks

1. **Error-table sign extension (real bug).** I2CErrText does `EXT.W`
   on the table byte — entries >= 0x80 become NEGATIVE offsets.  Slots
   4,5,7,12,14 (0x96 = intended "+0x96" -> "???"), 15 (0x90 -> "error")
   and 16 (0x96 -> "???") actually resolve to functab bytes (0x97 =
   '|' in the original).  So unknown codes return a pointer into the
   function table instead of "???"/"error".  Reproduced faithfully.
2. **Dead vestigial CIA code.** Write/read load `lea $bfd000,a0`
   (CIAB PRA) and `move.l delay,d5` — neither is ever used.  Leftover
   from a CIA-bit-banged predecessor.
3. **Dead second interrupt node.** intr2 @0xac is fully datatab-inited
   (type 2, pri 0x7d, name) but never AddIntServer'd; is_Data/is_Code
   stay 0.
4. **Dead -48 vector.** Tests `present`, both branches -> `moveq #0,rts`
   (a compiled-out wait-ready).  Called by Open/ReEnable anyway.
5. **Private delayed-expunge.** Uses base+0x43 bit 3 instead of
   `lib_Flags LIBF_DELEXP` — works, but nonstandard.
6. **Open discards probe result.** LibOpen always returns the base;
   a missing/busy board is only visible via later transfer errors.
7. **Sticky state.** Once expansion-open fails, state=3 makes every
   probe return 3 forever (cached, never retried).
8. **stale state byte in results.** Packed return uses `state` captured
   before the transfer, so a close-expunge can leak the *previous*
   state into byte3.
9. **Start stub returns 10.** `_start` is `moveq #10,d0;rts` — nonzero,
   unlike the usual `moveq #0` — harmless (AUTOINIT ignores it; the
   initfunc path is what matters).
10. **I2CXTAL low byte.** Crystal matching is `CMPI.B` on the parsed
    value's low byte only — 0x103 reads as 3 MHz.
11. **Trailing NAK swallowed.** A no-ack on the last data byte of a
    write (len already 0) returns err=0 success.
12. **Return-value hole in expunge path.** LibClose only propagates
    the seglist when OpenCnt hits 0 AND dexp set — fine — but
    Expunge-on-open leaves the lib live and returns 0.
